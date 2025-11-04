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

/// Generic verify for all binary ops
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
//===----------------------------------------------------------------------===//
// MatmulOp
//===----------------------------------------------------------------------===//

LogicalResult MatmulOp::verify() { return verifyBinaryOp(*this); }

/// Type inference for matrix multiplication
LogicalResult MatmulOp::inferReturnTypes(
    MLIRContext *context,
    std::optional<Location> location,
    ValueRange operands,
    DictionaryAttr attributes,
    OpaqueProperties properties,
    RegionRange regions,
    SmallVectorImpl<Type> &inferredReturnTypes) {
  
  if (operands.size() != 2) {
    if (location) {
      mlir::emitError(*location) << "matmul requires exactly 2 operands";
    }
    return failure();
  }

  auto lhsType = llvm::dyn_cast<TensorType>(operands[0].getType());
  auto rhsType = llvm::dyn_cast<TensorType>(operands[1].getType());
  
  if (!lhsType || !rhsType) {
    if (location) {
      mlir::emitError(*location) << "matmul operands must be tensor types";
    }
    return failure();
  }

  Type elementType = lhsType.getElementType();
  if (elementType != rhsType.getElementType()) {
    if (location) {
      mlir::emitError(*location) << "matmul operands must have the same element type";
    }
    return failure();
  }

  if (!lhsType.hasRank() || !rhsType.hasRank()) {
    inferredReturnTypes.push_back(UnrankedTensorType::get(elementType));
    return success();
  }

  ArrayRef<int64_t> lhsShape = lhsType.getShape();
  ArrayRef<int64_t> rhsShape = rhsType.getShape();

  if (lhsShape.size() < 1 || rhsShape.size() < 1) {
    if (location) {
      mlir::emitError(*location) << "matmul operands must have at least rank 1";
    }
    return failure();
  }

  SmallVector<int64_t, 4> resultShape;

  // 1D x 1D: dot product -> scalar
  if (lhsShape.size() == 1 && rhsShape.size() == 1) {
    if (lhsShape[0] != rhsShape[0] && 
        lhsShape[0] != ShapedType::kDynamic && 
        rhsShape[0] != ShapedType::kDynamic) {
      if (location) {
        mlir::emitError(*location) << "matmul: incompatible dimensions: "
                                    << lhsShape[0] << " vs " << rhsShape[0];
      }
      return failure();
    }
    inferredReturnTypes.push_back(RankedTensorType::get({}, elementType));
    return success();
  }

  // Matrix multiplication: [..., M, K] x [..., K, N] -> [..., M, N]
  int64_t lhsK = lhsShape[lhsShape.size() - 1];
  int64_t rhsK = (rhsShape.size() == 1) ? rhsShape[0] : rhsShape[rhsShape.size() - 2];

  if (lhsK != rhsK && 
      lhsK != ShapedType::kDynamic && 
      rhsK != ShapedType::kDynamic) {
    if (location) {
      mlir::emitError(*location) << "matmul: incompatible dimensions: " << lhsK << " vs " << rhsK;
    }
    return failure();
  }

  // Batch dimensions
  size_t lhsBatchRank = lhsShape.size() > 2 ? lhsShape.size() - 2 : 0;
  size_t rhsBatchRank = rhsShape.size() > 2 ? rhsShape.size() - 2 : 0;
  size_t maxBatchRank = std::max(lhsBatchRank, rhsBatchRank);
  
  for (size_t i = 0; i < maxBatchRank; ++i) {
    int64_t lhsDim = (i < lhsBatchRank) ? lhsShape[lhsBatchRank - 1 - i] : 1;
    int64_t rhsDim = (i < rhsBatchRank) ? rhsShape[rhsBatchRank - 1 - i] : 1;
    
    if (lhsDim == rhsDim || lhsDim == 1 || rhsDim == 1 ||
        lhsDim == ShapedType::kDynamic || rhsDim == ShapedType::kDynamic) {
      resultShape.insert(resultShape.begin(), (lhsDim == 1) ? rhsDim : lhsDim);
    } else {
      if (location) {
        mlir::emitError(*location) << "matmul: incompatible batch dimensions";
      }
      return failure();
    }
  }

  if (lhsShape.size() >= 2) {
    resultShape.push_back(lhsShape[lhsShape.size() - 2]);
  }
  
  if (rhsShape.size() >= 2) {
    resultShape.push_back(rhsShape[rhsShape.size() - 1]);
  }

  inferredReturnTypes.push_back(RankedTensorType::get(resultShape, elementType));
  return success();
}