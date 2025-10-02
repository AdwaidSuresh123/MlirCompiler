#ifndef NOVA_TYPEINFERENCE_H
#define NOVA_TYPEINFERENCE_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Types.h"
#include "mlir/Support/LogicalResult.h"

namespace mlir {
namespace nova {

// General type inference results
struct TypeInferenceResult {
  bool success;
  Type inferredType;
  std::string errorMessage;
};

// General type inference utilities
class TypeInference {
public:
  // Infer result type for unary operations (like neg, sin, cos, etc.)
  static TypeInferenceResult inferUnaryOp(Type operandType);
  
  // Infer result type for binary operations (like add, sub, mul, etc.)
  static TypeInferenceResult inferBinaryOp(Type lhsType, Type rhsType);
  
  // Check if two types are compatible for binary operations
  static LogicalResult checkBinaryOpCompatibility(Type lhsType, Type rhsType, 
                                                 std::optional<Location> loc = std::nullopt);
  
  // Check if type is supported by Nova dialect
  static bool isSupportedType(Type type);
  
  // Get the element type from tensor or return the type itself
  static Type getElementType(Type type);
  
  // Check if types have same shape (for tensors)
  static bool haveSameShape(Type type1, Type type2);
  
  // Common error messages
  static inline const std::string ERR_INCOMPATIBLE_TYPES = "incompatible types";
  static inline const std::string ERR_UNSUPPORTED_TYPE = "unsupported type";
  static inline const std::string ERR_SHAPE_MISMATCH = "shape mismatch";
  static inline const std::string ERR_INVALID_OPERAND_COUNT = "invalid operand count";
};

} // namespace nova
} // namespace mlir

#endif // NOVA_TYPEINFERENCE_H