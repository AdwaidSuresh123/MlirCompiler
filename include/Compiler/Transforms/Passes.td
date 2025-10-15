#ifndef NOVA_TRANSFORMS_PASSES
#define NOVA_TRANSFORMS_PASSES

include "mlir/Pass/PassBase.td"

def ConstantFolding : Pass<"constant-folding", "::mlir::func::FuncOp"> {
  let summary = "Fold constant arithmetic operations";
  let description = [{
    This pass folds arithmetic operations where all operands are constants.
    
    Example:
      %c2 = arith.constant 2 : i32
      %c3 = arith.constant 3 : i32
      %0 = arith.addi %c2, %c3 : i32
    
    Becomes:
      %0 = arith.constant 5 : i32
  }];
  
  let constructor = "mlir::nova::createConstantFoldingPass()";
}

// Add this to your existing Passes.td file

#endif // NOVA_TRANSFORMS_PASSES