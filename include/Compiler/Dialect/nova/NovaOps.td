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
//===-----------------------------------------------------------------------------===//
// TODO : Dont add elementwise int the operation. We will add it in lowering pass
//===-----------------------------------------------------------------------------===//

def Nova_BroadcastInDimOp : Op<Nova_Dialect, "broadcast_in_dim", [
    Pure
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
}

//===----------------------------------------------------------------------===//
// Base class for binary elementwise tensor ops
//===----------------------------------------------------------------------===//

class Nova_BinaryOp<string mnemonic, list<Trait> commonTraits = []>: 
  Op<Nova_Dialect, mnemonic,
     commonTraits # [Pure,
                     InferTypeOpInterface,
                     SameOperandsAndResultElementType]> {

  let arguments = (ins Nova_Tensor:$lhs, Nova_Tensor:$rhs);
  let results = (outs Nova_Tensor:$result);

  let assemblyFormat = [{
    $lhs `,` $rhs attr-dict `:` type($lhs) `,` type($rhs) `->` type($result)
  }];

  let hasCanonicalizer = 1;
  let hasVerifier = 1;

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

//===----------------------------------------------------------------------===//
// Binary Operations
//===----------------------------------------------------------------------===//

def Nova_AddOp : Nova_BinaryOp<"add", [Commutative]> {
  let summary = "Elementwise tensor addition";
  let description = [{
    Adds two tensors elementwise with broadcasting support.
    
    Example:
      %r = nova.add %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_SubOp : Nova_BinaryOp<"sub", []> {
  let summary = "Elementwise tensor subtraction";
  let description = [{
    Subtracts two tensors elementwise with broadcasting support.

    Example:
      %r = nova.sub %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_MulOp : Nova_BinaryOp<"mul", [Commutative]> {
  let summary = "Elementwise tensor multiplication";
  let description = [{
    Multiplies two tensors elementwise with broadcasting support.
    Example: [1,2,3] * [3,4,5] = [3,8,15]

    Example:
      %r = nova.mul %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_DivOp : Nova_BinaryOp<"div", []> {
  let summary = "Elementwise tensor division";
  let description = [{
    Divides two tensors (dividend and divisor) elementwise with broadcasting support.
    
    Example:
      %r = nova.div %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_RemOp : Nova_BinaryOp<"rem", []> {
  let summary = "Elementwise tensor remainder";
  let description = [{
    Performs element-wise remainder of dividend lhs and divisor rhs.
    Computation example: a=[2,7,10] b=[2,2,4] result=[0,1,2]
  
    Example:
      %r = nova.rem %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_PowOp : Nova_BinaryOp<"pow", []> {
  let summary = "Elementwise tensor power";
  let description = [{
    Performs element-wise power: lhs^rhs.
    Computation example: a=[1,2,3] b=[2,2,4] result=[1,4,81]
  
    Example:
      %r = nova.pow %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_MaxOp : Nova_BinaryOp<"max", [Commutative]> {
  let summary = "Elementwise tensor maximum";
  let description = [{
    Performs element-wise max operation on tensors.
    Example: a=[1,2,3] b=[2,4,2] result=[2,4,3]
  
    Example:
      %r = nova.max %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_MinOp : Nova_BinaryOp<"min", [Commutative]> {
  let summary = "Elementwise tensor minimum";
  let description = [{
    Performs element-wise min operation on tensors.
    Example: a=[1,2,3] b=[2,4,2] result=[1,2,2]
  
    Example:
      %r = nova.min %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
  }];
}

def Nova_AndOp : Nova_BinaryOp<"and", [Commutative]> {
  let summary = "Elementwise logical AND";
  let description = [{
    Performs element-wise logical AND operation on tensors.
    Example: a=[true,false,true] b=[true,true,false] result=[true,false,false]
  
    Example:
      %r = nova.and %a, %b : tensor<2x3xi1>, tensor<3xi1> -> tensor<2x3xi1>
  }];
}

def Nova_OrOp : Nova_BinaryOp<"or", [Commutative]> {
  let summary = "Elementwise logical OR";
  let description = [{
    Performs element-wise logical OR operation on tensors.
    Example: a=[true,false,true] b=[true,true,false] result=[true,true,true]
  
    Example:
      %r = nova.or %a, %b : tensor<2x3xi1>, tensor<3xi1> -> tensor<2x3xi1>
  }];
}

def Nova_XorOp : Nova_BinaryOp<"xor", [Commutative]> {
  let summary = "Elementwise logical XOR";
  let description = [{
    Performs element-wise logical XOR operation on tensors.
    Example: a=[true,false,true] b=[true,true,false] result=[false,true,true]
  
    Example:
      %r = nova.xor %a, %b : tensor<2x3xi1>, tensor<3xi1> -> tensor<2x3xi1>
  }];
}

#endif // NOVA_OPS