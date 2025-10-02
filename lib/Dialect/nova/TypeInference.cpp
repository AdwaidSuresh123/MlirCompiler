#include "Compiler/Dialect/nova/TypeInference.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/Types.h"
using namespace mlir;
using namespace mlir::nova;

// Infer result type for unary operations
TypeInferenceResult TypeInference::inferUnaryOp(Type operandType) {
  TypeInferenceResult result;
  
  if (!isSupportedType(operandType)) {
    result.success = false;
    result.errorMessage = ERR_UNSUPPORTED_TYPE;
    return result;
  }
  
  // For unary ops, result type is same as operand type
  result.success = true;
  result.inferredType = operandType;
  return result;
}

// Infer result type for binary operations
TypeInferenceResult TypeInference::inferBinaryOp(Type lhsType, Type rhsType) {
  TypeInferenceResult result;
  
  // Check if both types are supported
  if (!isSupportedType(lhsType) || !isSupportedType(rhsType)) {
    result.success = false;
    result.errorMessage = ERR_UNSUPPORTED_TYPE;
    return result;
  }
  
  // Check compatibility
  if (failed(checkBinaryOpCompatibility(lhsType, rhsType))) {
    result.success = false;
    result.errorMessage = ERR_INCOMPATIBLE_TYPES;
    return result;
  }
  
  // For now, return lhs type (you can enhance this for type promotion)
  result.success = true;
  result.inferredType = lhsType;
  return result;
}

// Check if two types are compatible for binary operations
LogicalResult TypeInference::checkBinaryOpCompatibility(Type lhsType, Type rhsType, 
                                                       std::optional<Location> loc) {
  // If both are tensors, check shapes
  auto lhsTensor = dyn_cast<TensorType>(lhsType);
  auto rhsTensor = dyn_cast<TensorType>(rhsType);
  
  if (lhsTensor && rhsTensor) {
    if (!haveSameShape(lhsTensor, rhsTensor)) {
      if (loc) {
        emitError(*loc) << "binary operation requires tensors with same shape";
      }
      return failure();
    }
    
    // Check element type compatibility
    Type lhsElem = getElementType(lhsTensor);
    Type rhsElem = getElementType(rhsTensor);
    
    if (lhsElem != rhsElem) {
      if (loc) {
        emitError(*loc) << "binary operation requires same element types";
      }
      return failure();
    }
  }
  // If one is tensor and other is not
  else if (lhsTensor || rhsTensor) {
    if (loc) {
      emitError(*loc) << "cannot mix tensor and scalar types in binary operation";
    }
    return failure();
  }
  // Both are scalars - check if they are the same type
  else if (lhsType != rhsType) {
    if (loc) {
      emitError(*loc) << "scalar binary operation requires same types";
    }
    return failure();
  }
  
  return success();
}

// Check if type is supported by Nova dialect
bool TypeInference::isSupportedType(Type type) {
  // Handle tensor types
  if (auto tensorType = dyn_cast<TensorType>(type)) {
    return isSupportedType(tensorType.getElementType());
  }
  
  // Supported scalar types
  return type.isIntOrIndex() || 
         isa<FloatType>(type) || 
         type.isInteger(1) ||      // boolean
         isa<ComplexType>(type);
}

// Get the element type from tensor or return the type itself
Type TypeInference::getElementType(Type type) {
  if (auto tensorType = dyn_cast<TensorType>(type)) {
    return tensorType.getElementType();
  }
  return type;
}

// Check if types have same shape (for tensors)
bool TypeInference::haveSameShape(Type type1, Type type2) {
  auto tensor1 = dyn_cast<TensorType>(type1);
  auto tensor2 = dyn_cast<TensorType>(type2);
  
  if (!tensor1 || !tensor2) {
    return false;
  }
  
  return tensor1.getShape() == tensor2.getShape();
}