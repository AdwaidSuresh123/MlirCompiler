#ifndef NOVA_OPS
#define NOVA_OPS

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "NovaDialect.td"

def Nova_ElementType : AnyTypeOf<[I1, I8, I16, I32, I64, F16, BF16, F32, F64]>;
def Nova_Tensor : TensorOf<[Nova_ElementType]>;

//===----------------------------------------------------------------------===//
// Nova broadcasting.
//===----------------------------------------------------------------------===//

def Nova_BroadcastInDimOp : Op<Nova_Dialect, "broadcast_in_dim", [
    Pure,
    InferTypeOpInterface
  ]> {
  let summary = "Broadcast operation";
  let description = [{
    Expands dimensions of input tensor by replicating data.
    
    The `broadcast_dimensions` attribute maps operand dimensions to result dimensions.
    
    Example:
      // Broadcast [3] to [2, 3]
      %result = nova.broadcast_in_dim %input, dims = [1] : (tensor<3xf32>) -> tensor<2x3xf32>
  }];

  let arguments = (ins
    Nova_Tensor:$operand,
    I64ArrayAttr:$broadcast_dimensions
  );
  
  let results = (outs Nova_Tensor:$result);
  
  let assemblyFormat = [{
    $operand `,` `dims` `=` $broadcast_dimensions attr-dict `:`
    `(` type($operand) `)` `->` type($result)
  }];
  
  let hasVerifier = 1;

  // FIXED: Full signature, no defaults (avoids brace-init error)
  let extraClassDeclaration = [{
    static LogicalResult inferReturnTypes(MLIRContext *context, std::optional<Location> location,
                                          ValueRange operands, DictionaryAttr attributes,
                                          OpaqueProperties properties, RegionRange regions,
                                          SmallVectorImpl<Type> &inferredReturnTypes);
  }];
}

//===----------------------------------------------------------------------===//
// Nova binary elementwise op definitions.
//===----------------------------------------------------------------------===//

def Nova_AddOp : Op<Nova_Dialect, "add", [
    Pure,
    Commutative,
    InferTypeOpInterface
  ]> {
  let summary = "Elementwise addition";
  let description = [{
    Performs element-wise addition. 
    
    Note: If operands have different shapes, use broadcast_in_dim first
    to make them compatible, or use type inference to create the operation
    with broadcasting semantics that will be canonicalized.
    
    Example:
      %result = nova.add %lhs, %rhs : tensor<2x3xf32>, tensor<2x3xf32> -> tensor<2x3xf32>
  }];

  let arguments = (ins Nova_Tensor:$lhs, Nova_Tensor:$rhs);
  let results = (outs Nova_Tensor:$result);
  
  let assemblyFormat = [{
    $lhs `,` $rhs attr-dict `:` type($lhs) `,` type($rhs) `->` type($result)
  }];
  
  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  // FIXED: Full signature, no defaults (avoids brace-init error)
  let extraClassDeclaration = [{
    static LogicalResult inferReturnTypes(MLIRContext *context, std::optional<Location> location,
                                          ValueRange operands, DictionaryAttr attributes,
                                          OpaqueProperties properties, RegionRange regions,
                                          SmallVectorImpl<Type> &inferredReturnTypes);
  }];
}

#endif // NOVA_OPS