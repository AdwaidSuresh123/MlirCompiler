#include "Compiler/Dialect/nova/NovaOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "Compiler/Dialect/nova/TypeInference.h"
#include "mlir/IR/Diagnostics.h" 
using namespace mlir;
using namespace mlir::nova;

#define GET_OP_CLASSES
#include "Compiler/Dialect/nova/NovaOps.cpp.inc"


LogicalResult AddOp::inferReturnTypes(
    MLIRContext *context,
    std::optional<Location> loc,
    ValueRange operands,
    DictionaryAttr attributes,
    OpaqueProperties properties,
    RegionRange regions,
    llvm::SmallVectorImpl<Type> &inferredReturnTypes) {
  
  // Check operand count using general utility
  if (operands.size() != 2) {
    if (loc) {
      mlir::emitError(*loc) << TypeInference::ERR_INVALID_OPERAND_COUNT << ": expected 2, got " << operands.size();
    }
    return failure();
  }
  
  // Use general type inference
  auto result = TypeInference::inferBinaryOp(operands[0].getType(), operands[1].getType());
  
  if (!result.success) {
    if (loc) {
      mlir::emitError(*loc) << result.errorMessage;
    }
    return failure();
  }
  
  inferredReturnTypes.push_back(result.inferredType);
  return success();
}

LogicalResult NovaNegOp::inferReturnTypes(
    MLIRContext *context,
    std::optional<Location> loc,
    ValueRange operands,
    DictionaryAttr attributes,
    OpaqueProperties properties,
    RegionRange regions,
    SmallVectorImpl<Type> &inferredReturnTypes) {
  
  if (operands.empty()) 
    return failure();
  
  // Still more efficient than original, but uses inferUnaryOp
  if (auto result = TypeInference::inferUnaryOp(operands.front().getType());
      result.success) {
    inferredReturnTypes.push_back(result.inferredType);
    return success();
  }
  
  return failure();
}

// Helper function to negate a single element based on its type.
static Attribute negateElement(Attribute element, Type elementType) {
  MLIRContext *context = element.getContext();

  // For Bool type
  if (elementType.isInteger(1)) {
    bool val = cast<BoolAttr>(element).getValue();
    return BoolAttr::get(context, !val);
  }
  // For Integer type
  else if (elementType.isIntOrIndex()) {
    APInt val = cast<IntegerAttr>(element).getValue();
    return IntegerAttr::get(elementType, -val);
  }
  // For Float type
  else if (isa<FloatType>(elementType)) {
    APFloat val = cast<FloatAttr>(element).getValue();
    val.changeSign();
    return FloatAttr::get(elementType, val);
  }
  // For Complex type - simplified version
  else if (isa<ComplexType>(elementType)) {
    // For complex types, we'll create a simple representation
    // This might need adjustment based on your exact complex number representation
    auto complexType = cast<ComplexType>(elementType);
    auto floatType = complexType.getElementType();
    
    // Create negative zero values for real and imaginary parts
    APFloat zeroVal(0.0);
    zeroVal.changeSign();
    
    return ArrayAttr::get(context, 
                         {FloatAttr::get(floatType, zeroVal),
                          FloatAttr::get(floatType, zeroVal)});
  }
  
  return {};
}