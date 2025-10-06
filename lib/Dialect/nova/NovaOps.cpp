#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/Broadcast.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/TypeUtilities.h"
#include <optional>  // NEW: For std::optional (if not included elsewhere)

using namespace mlir;
using namespace mlir::nova;

#define GET_OP_CLASSES
#include "Compiler/Dialect/nova/NovaOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Replaces raw computeBroadcastShape calls for better error reporting.
static LogicalResult tryBroadcastShape(std::optional<Location> loc,
                                       llvm::ArrayRef<int64_t> lhsShape,
                                       llvm::ArrayRef<int64_t> rhsShape,
                                       llvm::SmallVectorImpl<int64_t> &outShape) {
  auto maybeShape = computeBroadcastShape(lhsShape, rhsShape);
  if (!maybeShape) {
    if (loc) {
      mlir::emitError(*loc, "Incompatible shapes for broadcasting: ")
          << lhsShape << " and " << rhsShape;
    }
    return failure();
  }
  outShape = std::move(*maybeShape);
  return success();
}

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
  
  // Handle unranked tensors
  if (!lhsType.hasRank() || !rhsType.hasRank()) {
    inferredReturnTypes.push_back(UnrankedTensorType::get(elementType));
    return success();
  }
  
  // CHANGED: Use the new tryBroadcastShape for cleaner diagnostics
  llvm::SmallVector<int64_t> broadcastedShape;
  if (failed(tryBroadcastShape(loc, lhsType.getShape(), rhsType.getShape(), broadcastedShape))) {
    return failure();
  }
  
  // Create result type with broadcasted shape
  inferredReturnTypes.push_back(
    RankedTensorType::get(broadcastedShape, elementType));
  
  return success();
}

//===----------------------------------------------------------------------===//
// BroadcastInDimOp
//===----------------------------------------------------------------------===//

// UNCHANGED: verify() is perfect as-is
LogicalResult BroadcastInDimOp::verify() {
  auto operandType = dyn_cast<RankedTensorType>(getOperand().getType());
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  
  // If either is unranked, we can't verify shape constraints
  if (!operandType || !resultType) {
    return success();
  }
  
  auto broadcastDims = getBroadcastDimensions();

  // Verify broadcast_dimensions size matches operand rank
  if (static_cast<int64_t>(broadcastDims.size()) != operandType.getRank()) {
    return emitOpError("broadcast_dimensions size (")
           << broadcastDims.size() << ") must match operand rank ("
           << operandType.getRank() << ")";
  }

  // Verify each broadcast dimension is valid
  llvm::SmallVector<bool> seenDims(resultType.getRank(), false);
  
  for (auto [idx, dim] : llvm::enumerate(broadcastDims)) {
    // Get the integer value from the attribute
    int64_t dimValue = cast<IntegerAttr>(dim).getInt();
    
    // Check dimension is in valid range
    if (dimValue < 0 || dimValue >= resultType.getRank()) {
      return emitOpError("broadcast dimension ") << dimValue 
             << " out of range [0, " << resultType.getRank() << ")";
    }
    
    // Check dimension is not used multiple times
    if (seenDims[dimValue]) {
      return emitOpError("broadcast dimension ") << dimValue 
             << " is used more than once";
    }
    seenDims[dimValue] = true;
    
    // Check size compatibility
    int64_t operandDim = operandType.getDimSize(idx);
    int64_t resultDim = resultType.getDimSize(dimValue);
    
    // Operand dimension must be 1 or equal to result dimension
    if (!ShapedType::isDynamic(operandDim) && 
        !ShapedType::isDynamic(resultDim)) {
      if (operandDim != 1 && operandDim != resultDim) {
        return emitOpError() << "operand dimension " << idx 
                             << " (size " << operandDim << ") "
                             << "incompatible with result dimension " << dimValue
                             << " (size " << resultDim << ")";
      }
    }
  }

  return success();
}


LogicalResult BroadcastInDimOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
      auto operandType = dyn_cast<RankedTensorType>(getOperand().getType());
      auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
      if (!operandType || !resultType) {
        inferredReturnTypes.push_back(UnrankedTensorType::get(operandType.getElementType()));
        return success();
      }
      inferredReturnTypes.push_back(resultType);
  return failure();
}

//===----------------------------------------------------------------------===//
// AddOp
//===----------------------------------------------------------------------===//

// UNCHANGED: verify() is solid
LogicalResult AddOp::verify() {
  auto lhsType = getLhs().getType();
  auto rhsType = getRhs().getType();
  auto resultType = getResult().getType();
  
  // For now, just verify that all types are tensors
  // The broadcasting canonicalization will handle shape mismatches
  if (!isa<TensorType>(lhsType) || !isa<TensorType>(rhsType) || 
      !isa<TensorType>(resultType)) {
    return emitOpError("operands and result must be tensor types");
  }
  
  // Verify element types match
  auto lhsElementType = cast<TensorType>(lhsType).getElementType();
  auto rhsElementType = cast<TensorType>(rhsType).getElementType();
  auto resultElementType = cast<TensorType>(resultType).getElementType();
  
  if (lhsElementType != rhsElementType || lhsElementType != resultElementType) {
    return emitOpError("operands and result must have the same element type");
  }
  
  return success();
}

// UNCHANGED: Now uses the updated template
LogicalResult AddOp::inferReturnTypes(
    MLIRContext *context, std::optional<Location> loc, ValueRange operands,
    DictionaryAttr attributes, OpaqueProperties properties,
    RegionRange regions, llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  return inferBinaryElementwiseReturnTypes<AddOp>(
      context, loc, operands, attributes, properties, regions, inferredReturnTypes);
}

namespace {
  
template<typename OpType>
struct InsertBroadcastPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto lhsType = dyn_cast<RankedTensorType>(op.getLhs().getType());
    auto rhsType = dyn_cast<RankedTensorType>(op.getRhs().getType());
    auto resultType = dyn_cast<RankedTensorType>(op.getResult().getType());

    // If any type is unranked, can't canonicalize
    if (!lhsType || !rhsType || !resultType) {
      return failure();
    }

    // If shapes already match, nothing to do
    if (lhsType.getShape() == resultType.getShape() &&
        rhsType.getShape() == resultType.getShape()) {
      return failure();
    }

    // Insert broadcast operations as needed
    Value newLhs = op.getLhs();
    Value newRhs = op.getRhs();
    bool changed = false;

    if (lhsType.getShape() != resultType.getShape()) {
      // CHANGED: Add rank check and compat check for safety
      if (lhsType.getRank() > resultType.getRank()) {
        return failure();  // Can't broadcast to smaller rank
      }
      if (!isBroadcastCompatible(lhsType.getShape(), resultType.getShape())) {
        return failure();  // Incompatible; let verify/inference catch it
      }
      
      auto broadcastDims = computeBroadcastDimensions(
          lhsType.getRank(), resultType.getRank());
      
      auto broadcastDimsAttr = rewriter.getI64ArrayAttr(broadcastDims);
      
      newLhs = rewriter.create<BroadcastInDimOp>(
          op.getLoc(), resultType, newLhs, broadcastDimsAttr).getResult();
      changed = true;
    }

    if (rhsType.getShape() != resultType.getShape()) {
      // CHANGED: Same rank/compat checks for RHS
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

    // Create new operation with broadcasted operands
    rewriter.replaceOpWithNewOp<OpType>(op, op.getResult().getType(), newLhs, newRhs);
    return success();
  }
};
} // namespace

// UNCHANGED: Registration is fine
void AddOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<AddOp>>(context);
}