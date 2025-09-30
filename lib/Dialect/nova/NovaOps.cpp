#include "Compiler/Dialect/nova/NovaOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"

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
  
  // Check we have exactly 2 operands
  if (operands.size() != 2) {
    if (loc){
      mlir::emitError(*loc, "nova.add requires exactly 2 operands");
      return failure();
    }
    return failure();
  }
  
  // Get the types of the operands
  auto lhsType = llvm::dyn_cast<TensorType>(operands[0].getType());
  auto rhsType = llvm::dyn_cast<TensorType>(operands[1].getType());
  
  // Verify both operands are tensors
  if (!lhsType || !rhsType) {
    if (loc){
      mlir::emitError(*loc, "nova.add operands must be tensors");
      return failure();
    }
    return failure();
  }
  
  // For now, we assume result type is same as lhs type
  // (Later, when you add broadcasting, this will be more complex)
  inferredReturnTypes.push_back(lhsType);
  
  return success();
}