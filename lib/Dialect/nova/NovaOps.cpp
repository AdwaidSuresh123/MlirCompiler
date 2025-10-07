#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/Broadcast.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/TypeUtilities.h"

using namespace mlir;
using namespace mlir::nova;

#define GET_OP_CLASSES
#include "Compiler/Dialect/nova/NovaOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Shared implementation for binary elementwise type inference with broadcasting
template<typename OpType>
static LogicalResult inferBinaryElementwiseReturnTypes(
    MLIRContext *context,
    std::optional<Location> loc,
    ValueRange operands,
    DictionaryAttr attributes,
    OpaqueProperties properties,
    RegionRange regions,
    llvm::SmallVectorImpl<Type> &inferredReturnTypes) {

  if (operands.size() != 2) {
    if (loc) {
      mlir::emitError(*loc) << OpType::getOperationName() 
                            << " requires exactly 2 operands";
    }
    return failure();
  }
  
  auto lhsType = llvm::dyn_cast<TensorType>(operands[0].getType());
  auto rhsType = llvm::dyn_cast<TensorType>(operands[1].getType());
  
  if (!lhsType || !rhsType) {
    if (loc) {
      mlir::emitError(*loc) << OpType::getOperationName() 
                            << " operands must be tensor types";
    }
    return failure();
  }

  Type elementType = lhsType.getElementType();
  
  if (elementType != rhsType.getElementType()) {
    if (loc) {
      mlir::emitError(*loc) << OpType::getOperationName() 
                            << " operands must have the same element type";
    }
    return failure();
  }
  
  if (!lhsType.hasRank() || !rhsType.hasRank()) {
    inferredReturnTypes.push_back(UnrankedTensorType::get(elementType));
    return success();
  }
  
  auto broadcastedShape = computeBroadcastShape(lhsType.getShape(), 
                                                rhsType.getShape());
  
  if (!broadcastedShape) {
    if (loc) {
      mlir::emitError(*loc) 
        << OpType::getOperationName() 
        << ": incompatible shapes for broadcasting - "
        << lhsType << " and " << rhsType;
    }
    return failure();
  }
  
  inferredReturnTypes.push_back(
    RankedTensorType::get(*broadcastedShape, elementType));
  
  return success();
}

//===----------------------------------------------------------------------===//
// BroadcastInDimOp
//===----------------------------------------------------------------------===//

LogicalResult BroadcastInDimOp::verify() {
  auto operandType = dyn_cast<RankedTensorType>(getOperand().getType());
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  
  if (!operandType || !resultType) {
    return success();
  }
  
  auto broadcastDims = getBroadcastDimensions();

  if (static_cast<int64_t>(broadcastDims.size()) != operandType.getRank()) {
    return emitOpError("broadcast_dimensions size (")
           << broadcastDims.size() << ") must match operand rank ("
           << operandType.getRank() << ")";
  }

  llvm::SmallVector<bool> seenDims(resultType.getRank(), false);
  
  for (auto [idx, dimAttr] : llvm::enumerate(broadcastDims)) {
    int64_t dim = cast<IntegerAttr>(dimAttr).getInt();
    
    if (dim < 0 || dim >= resultType.getRank()) {
      return emitOpError("broadcast dimension ") << dim 
             << " out of range [0, " << resultType.getRank() << ")";
    }
    
    if (seenDims[dim]) {
      return emitOpError("broadcast dimension ") << dim 
             << " is used more than once";
    }
    seenDims[dim] = true;
    
    int64_t operandDim = operandType.getDimSize(idx);
    int64_t resultDim = resultType.getDimSize(dim);
    
    if (!ShapedType::isDynamic(operandDim) && 
        !ShapedType::isDynamic(resultDim)) {
      if (operandDim != 1 && operandDim != resultDim) {
        return emitOpError() << "operand dimension " << idx 
                             << " (size " << operandDim << ") "
                             << "incompatible with result dimension " << dim
                             << " (size " << resultDim << ")";
      }
    }
  }

  return success();
}

//===----------------------------------------------------------------------===//
// Generic Binary Op Implementation (used by all binary ops)
//===----------------------------------------------------------------------===//

// Generic verify for all binary ops
template<typename OpType>
static LogicalResult verifyBinaryOp(OpType op) {
  auto lhsType = op.getLhs().getType();
  auto rhsType = op.getRhs().getType();
  auto resultType = op.getResult().getType();
  
  if (!isa<TensorType>(lhsType) || !isa<TensorType>(rhsType) || 
      !isa<TensorType>(resultType)) {
    return op.emitOpError("operands and result must be tensor types");
  }
  
  auto lhsElementType = cast<TensorType>(lhsType).getElementType();
  auto rhsElementType = cast<TensorType>(rhsType).getElementType();
  auto resultElementType = cast<TensorType>(resultType).getElementType();
  
  if (lhsElementType != rhsElementType || lhsElementType != resultElementType) {
    return op.emitOpError("operands and result must have the same element type");
  }
  
  return success();
}

// Generic canonicalization pattern for all binary ops
template<typename OpType>
struct InsertBroadcastPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto lhsType = dyn_cast<RankedTensorType>(op.getLhs().getType());
    auto rhsType = dyn_cast<RankedTensorType>(op.getRhs().getType());
    auto resultType = dyn_cast<RankedTensorType>(op.getResult().getType());

    if (!lhsType || !rhsType || !resultType) {
      return failure();
    }

    if (lhsType.getShape() == resultType.getShape() &&
        rhsType.getShape() == resultType.getShape()) {
      return failure();
    }

    Value newLhs = op.getLhs();
    Value newRhs = op.getRhs();
    bool changed = false;

    if (lhsType.getShape() != resultType.getShape()) {
      if (lhsType.getRank() > resultType.getRank()) {
        return failure();
      }
      if (!isBroadcastCompatible(lhsType.getShape(), resultType.getShape())) {
        return failure();
      }
      
      auto broadcastDims = computeBroadcastDimensions(
          lhsType.getRank(), resultType.getRank());
      
      auto broadcastDimsAttr = rewriter.getI64ArrayAttr(broadcastDims);
      
      newLhs = rewriter.create<BroadcastInDimOp>(
          op.getLoc(), resultType, newLhs, broadcastDimsAttr).getResult();
      changed = true;
    }

    if (rhsType.getShape() != resultType.getShape()) {
      if (rhsType.getRank() > resultType.getRank()) {
        return failure();
      }
      if (!isBroadcastCompatible(rhsType.getShape(), resultType.getShape())) {
        return failure();
      }
      
      auto broadcastDims = computeBroadcastDimensions(
          rhsType.getRank(), resultType.getRank());
      
      auto broadcastDimsAttr = rewriter.getI64ArrayAttr(broadcastDims);
      
      newRhs = rewriter.create<BroadcastInDimOp>(
          op.getLoc(), resultType, newRhs, broadcastDimsAttr).getResult();
      changed = true;
    }

    if (!changed) {
      return failure();
    }

    rewriter.replaceOpWithNewOp<OpType>(op, op.getResult().getType(), newLhs, newRhs);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AddOp
//===----------------------------------------------------------------------===//

LogicalResult AddOp::verify() { return verifyBinaryOp(*this); }

LogicalResult AddOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<AddOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void AddOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<AddOp>>(context);
}

//===----------------------------------------------------------------------===//
// SubOp
//===----------------------------------------------------------------------===//

LogicalResult SubOp::verify() { return verifyBinaryOp(*this); }

LogicalResult SubOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<SubOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void SubOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<SubOp>>(context);
}

//===----------------------------------------------------------------------===//
// MulOp
//===----------------------------------------------------------------------===//

LogicalResult MulOp::verify() { return verifyBinaryOp(*this); }

LogicalResult MulOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<MulOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void MulOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MulOp>>(context);
}

//===----------------------------------------------------------------------===//
// DivOp
//===----------------------------------------------------------------------===//

LogicalResult DivOp::verify() { return verifyBinaryOp(*this); }

LogicalResult DivOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<DivOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void DivOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<DivOp>>(context);
}

//===----------------------------------------------------------------------===//
// RemOp
//===----------------------------------------------------------------------===//

LogicalResult RemOp::verify() { return verifyBinaryOp(*this); }

LogicalResult RemOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<RemOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void RemOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<RemOp>>(context);
}

//===----------------------------------------------------------------------===//
// PowOp
//===----------------------------------------------------------------------===//

LogicalResult PowOp::verify() { return verifyBinaryOp(*this); }

LogicalResult PowOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<PowOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void PowOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<PowOp>>(context);
}

//===----------------------------------------------------------------------===//
// MaxOp
//===----------------------------------------------------------------------===//

LogicalResult MaxOp::verify() { return verifyBinaryOp(*this); }

LogicalResult MaxOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<MaxOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void MaxOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MaxOp>>(context);
}

//===----------------------------------------------------------------------===//
// MinOp
//===----------------------------------------------------------------------===//

LogicalResult MinOp::verify() { return verifyBinaryOp(*this); }

LogicalResult MinOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<MinOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void MinOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MinOp>>(context);
}

//===----------------------------------------------------------------------===//
// AndOp
//===----------------------------------------------------------------------===//

LogicalResult AndOp::verify() { return verifyBinaryOp(*this); }

LogicalResult AndOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<AndOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void AndOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<AndOp>>(context);
}

//===----------------------------------------------------------------------===//
// OrOp
//===----------------------------------------------------------------------===//

LogicalResult OrOp::verify() { return verifyBinaryOp(*this); }

LogicalResult OrOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<OrOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void OrOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<OrOp>>(context);
}

//===----------------------------------------------------------------------===//
// XorOp
//===----------------------------------------------------------------------===//

LogicalResult XorOp::verify() { return verifyBinaryOp(*this); }

LogicalResult XorOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<XorOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

void XorOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<XorOp>>(context);
}