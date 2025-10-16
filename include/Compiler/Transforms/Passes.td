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

#endif // NOVA_TRANSFORMS_PASSES