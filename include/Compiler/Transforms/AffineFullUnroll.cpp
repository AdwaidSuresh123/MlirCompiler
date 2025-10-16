// AffineFullUnroll.cpp
#include "AffineFullUnroll.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Pass/Pass.h"


namespace mlir {
namespace nova {

#define GEN_PASS_DEF_AFFINEFULLUNROLL
#include "Compiler/Transforms/Passes.h.inc"



// A pass that manually walks the IR
struct AffineFullUnroll : impl::AffineFullUnrollBase<AffineFullUnroll> {
  using AffineFullUnrollBase::AffineFullUnrollBase;

  void runOnOperation() override {
    getOperation()->walk([&](mlir::affine::AffineForOp op) {
      if (failed(mlir::affine::loopUnrollFull(op))) {
        op.emitError("unrolling failed");
        signalPassFailure();
      }
    });
  }
};


} // namespace nova
} // namespace mlir