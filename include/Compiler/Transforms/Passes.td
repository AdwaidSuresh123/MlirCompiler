#ifndef NOVA_TRANSFORMS_PASSES
#define NOVA_TRANSFORMS_PASSES

include "mlir/Pass/PassBase.td"


def AffineFullUnroll:Pass<"affine-full-unroll">{
    let summary="Fully unroll all affine loops";
    let description=[{
        Full unroll all affine loops
    }];
    let dependentDialects=["mlir::affine::AffineDialect"];
}

def FuseMatmulInit : Pass<"fuse-matmul-init", "func::FuncOp"> {
    let summary = "Fuse matmul initialization with computation";
    let description = [{
        Fuses the initialization loop (storing zeros) with the
        matmul computation loop to eliminate redundant memory traffic.
    }];
    let dependentDialects = [
        "mlir::affine::AffineDialect",
        "mlir::arith::ArithDialect",
        "mlir::memref::MemRefDialect"
    ];
}

def FastmathFlag : Pass<"fastmath-flag", "func::FuncOp"> {
    let summary = "Add fastmath<contract> flags to enable FMA fusion";
    let description = [{
        Insert a fastmath flag so that math-uplift-to-fma pass can be triggered
    }];
    let dependentDialects = ["mlir::arith::ArithDialect"];
    let constructor = "::mlir::nova::createFastmathFlagPass()";
}

#endif // NOVA_TRANSFORMS_PASSES