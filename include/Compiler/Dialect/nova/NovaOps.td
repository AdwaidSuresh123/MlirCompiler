#ifndef NOVA_OPS
#define NOVA_OPS

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "NovaDialect.td"

def Nova_ElementType : AnyTypeOf<[I1, I8, I16, I32, I64, F16, BF16, F32, F64]>;
def Nova_Tensor : TensorOf<[Nova_ElementType]>;

def Nova_AddOp : Op<Nova_Dialect, "add", [Pure, InferTypeOpInterface]> {
  let summary = "Elementwise tensor addition";
  let description = [{
    Adds two tensors elementwise. Result type is automatically inferred.
    
    Example:
      %r = nova.add %a, %b : tensor<2x2xf32>, tensor<2x2xf32>
  }];

  let arguments = (ins Nova_Tensor:$lhs, Nova_Tensor:$rhs);
  let results = (outs Nova_Tensor:$result);
  
  // Fix the assembly format to include result type
  let assemblyFormat = "$lhs `,` $rhs attr-dict `:` type(operands)";

  let extraClassDeclaration = [{
    static ::mlir::LogicalResult inferReturnTypes(
      ::mlir::MLIRContext *context,
      std::optional<::mlir::Location> loc,
      ::mlir::ValueRange operands,
      ::mlir::DictionaryAttr attributes,
      ::mlir::OpaqueProperties properties,
      ::mlir::RegionRange regions,
      ::llvm::SmallVectorImpl<::mlir::Type> &inferredReturnTypes);
  }];
}
def NovaNegOp : Op<Nova_Dialect, "negate", [Pure, InferTypeOpInterface]> {
  let summary = "Elementwise tensor negation";
  let description = [{
    Negates a tensor elementwise. Result type is automatically inferred.

    Example:
      %r = nova.negate %a : tensor<2x2xf32>
  }];

  let arguments = (ins Nova_Tensor:$lhs);
  let results = (outs Nova_Tensor:$result);

  // Assembly format: include the operand and result type
  let assemblyFormat = "$lhs attr-dict `:` type($lhs)";

  // Declare the type inference method
  let extraClassDeclaration = [{
    static ::mlir::LogicalResult inferReturnTypes(
      ::mlir::MLIRContext *context,
      std::optional<::mlir::Location> loc,
      ::mlir::ValueRange operands,
      ::mlir::DictionaryAttr attributes,
      ::mlir::OpaqueProperties properties,
      ::mlir::RegionRange regions,
      ::llvm::SmallVectorImpl<::mlir::Type> &inferredReturnTypes);
  }];
}


#endif // NOVA_OPS
