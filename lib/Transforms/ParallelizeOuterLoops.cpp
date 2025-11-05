#include "Compiler/Transforms/ParallelizeOuterLoops.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Pass/Pass.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "parallelize-outer-loops"

using namespace mlir;
using namespace mlir::affine;

namespace mlir {
namespace nova {

struct ParallelizeOuterLoopsPass
    : public PassWrapper<ParallelizeOuterLoopsPass, OperationPass<func::FuncOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(ParallelizeOuterLoopsPass)

  void runOnOperation() override {
    auto func = getOperation();

    llvm::errs() << "=== ParallelizeOuterLoops Pass Starting on function: "
                 << func.getName() << " ===\n";

    // Find the two outermost affine.for loops
    SmallVector<AffineForOp, 4> topLevelLoops;
    for (auto &op : func.getBody().front()) {
      if (auto forOp = dyn_cast<AffineForOp>(op)) {
        topLevelLoops.push_back(forOp);
      }
    }

    if (topLevelLoops.empty()) {
      llvm::errs() << "No top-level affine loops found\n";
      return;
    }

    // Process each top-level loop
    for (auto outerLoop : topLevelLoops) {
      if (!shouldParallelize(outerLoop)) {
        llvm::errs() << "Loop doesn't match parallelization pattern, skipping\n";
        continue;
      }

      // Get the next nested loop (j dimension)
      AffineForOp innerLoop = getFirstNestedAffineFor(outerLoop);
      if (!innerLoop) {
        llvm::errs() << "No nested loop found, skipping\n";
        continue;
      }

      llvm::errs() << "Found candidate loop pair for parallelization\n";

      // Convert outer two loops to scf.parallel
      if (failed(convertToParallel(outerLoop, innerLoop))) {
        llvm::errs() << "Failed to convert to parallel loops\n";
        signalPassFailure();
        return;
      }

      llvm::errs() << "Successfully converted to parallel loops\n";
    }

    llvm::errs() << "=== ParallelizeOuterLoops Pass Complete ===\n";
  }

private:

  bool shouldParallelize(AffineForOp loop) {
    // Check if this loop contains matmul-like computation
    bool hasMul = false;
    bool hasAdd = false;

    loop.walk([&](Operation *op) {
      if (isa<arith::MulFOp>(op)) hasMul = true;
      if (isa<arith::AddFOp>(op)) hasAdd = true;
      return WalkResult::advance();
    });

    return hasMul && hasAdd;
  }

  AffineForOp getFirstNestedAffineFor(AffineForOp loop) {
    for (Operation &op : *loop.getBody()) {
      if (auto nestedLoop = dyn_cast<AffineForOp>(op)) {
        return nestedLoop;
      }
    }
    return nullptr;
  }

  LogicalResult convertToParallel(AffineForOp iLoop, AffineForOp jLoop) {
    // Strategy: Lower inner affine loops to SCF first, then create parallel outer loops
    OpBuilder builder(iLoop);
    Location loc = iLoop.getLoc();

    // Extract bounds for i loop
    auto iLower = getConstantBound(iLoop, /*isLower=*/true);
    auto iUpper = getConstantBound(iLoop, /*isLower=*/false);
    auto iStep = iLoop.getStep();

    // Extract bounds for j loop
    auto jLower = getConstantBound(jLoop, /*isLower=*/true);
    auto jUpper = getConstantBound(jLoop, /*isLower=*/false);
    auto jStep = jLoop.getStep();

    if (!iLower || !iUpper || !jLower || !jUpper) {
      llvm::errs() << "Non-constant loop bounds, cannot parallelize\n";
      return failure();
    }

    llvm::errs() << "Loop bounds: i=[" << *iLower << ", " << *iUpper << "], "
                 << "j=[" << *jLower << ", " << *jUpper << "]\n";

    // First, lower ALL affine loops inside jLoop to SCF
    SmallVector<AffineForOp> innerAffineLoops;
    jLoop.walk([&](AffineForOp innerLoop) {
      if (innerLoop != jLoop) {
        innerAffineLoops.push_back(innerLoop);
      }
    });

    // Lower inner affine loops to SCF (from innermost to outermost)
    for (auto it = innerAffineLoops.rbegin(); it != innerAffineLoops.rend(); ++it) {
      if (failed(lowerAffineForToSCF(*it))) {
        llvm::errs() << "Failed to lower inner affine loop\n";
        return failure();
      }
    }

    // Create constant values for bounds
    Value iLowerVal = builder.create<arith::ConstantIndexOp>(loc, *iLower);
    Value iUpperVal = builder.create<arith::ConstantIndexOp>(loc, *iUpper);
    Value iStepVal = builder.create<arith::ConstantIndexOp>(loc, iStep.getSExtValue());

    Value jLowerVal = builder.create<arith::ConstantIndexOp>(loc, *jLower);
    Value jUpperVal = builder.create<arith::ConstantIndexOp>(loc, *jUpper);
    Value jStepVal = builder.create<arith::ConstantIndexOp>(loc, jStep.getSExtValue());

    // Create scf.parallel operation
    auto parallelOp = builder.create<scf::ParallelOp>(
        loc,
        ValueRange{iLowerVal, jLowerVal},  // lowerBounds
        ValueRange{iUpperVal, jUpperVal},  // upperBounds
        ValueRange{iStepVal, jStepVal}     // steps
    );

    Block *parallelBody = &parallelOp.getRegion().front();
    Value parallelI = parallelBody->getArgument(0);
    Value parallelJ = parallelBody->getArgument(1);

    // Build the body by cloning everything inside j loop
    OpBuilder bodyBuilder = OpBuilder::atBlockBegin(parallelBody);
    IRMapping mapping;
    mapping.map(iLoop.getInductionVar(), parallelI);
    mapping.map(jLoop.getInductionVar(), parallelJ);

    // Clone all operations from j loop body
    for (Operation &op : jLoop.getBody()->without_terminator()) {
      Operation *cloned = bodyBuilder.clone(op, mapping);
      for (auto [oldResult, newResult] : llvm::zip(op.getResults(), cloned->getResults())) {
        mapping.map(oldResult, newResult);
      }
    }

    // Add terminator
    bodyBuilder.create<scf::ReduceOp>(loc);

    // Erase old loops
    iLoop.erase();

    llvm::errs() << "Created scf.parallel with IV mapping\n";
    return success();
  }

  LogicalResult lowerAffineForToSCF(AffineForOp affineLoop) {
    // Lower affine.for to scf.for, handling both constant and affine bounds
    OpBuilder builder(affineLoop);
    Location loc = affineLoop.getLoc();

    // Get lower bound value
    Value lowerVal;
    if (affineLoop.hasConstantLowerBound()) {
      lowerVal = builder.create<arith::ConstantIndexOp>(loc, affineLoop.getConstantLowerBound());
    } else {
      // Use affine.apply to materialize the bound
      lowerVal = builder.create<affine::AffineApplyOp>(
          loc, affineLoop.getLowerBoundMap(), affineLoop.getLowerBoundOperands());
    }

    // Get upper bound value
    Value upperVal;
    if (affineLoop.hasConstantUpperBound()) {
      upperVal = builder.create<arith::ConstantIndexOp>(loc, affineLoop.getConstantUpperBound());
    } else {
      // Use affine.apply to materialize the bound
      upperVal = builder.create<affine::AffineApplyOp>(
          loc, affineLoop.getUpperBoundMap(), affineLoop.getUpperBoundOperands());
    }

    Value stepVal = builder.create<arith::ConstantIndexOp>(loc, affineLoop.getStep().getSExtValue());

    auto scfLoop = builder.create<scf::ForOp>(loc, lowerVal, upperVal, stepVal);

    // Map induction variables
    IRMapping mapping;
    mapping.map(affineLoop.getInductionVar(), scfLoop.getInductionVar());

    // Clone body, converting affine.load/store to memref.load/store
    OpBuilder bodyBuilder = OpBuilder::atBlockBegin(scfLoop.getBody());
    for (Operation &op : affineLoop.getBody()->without_terminator()) {
      if (auto loadOp = dyn_cast<affine::AffineLoadOp>(op)) {
        // Convert affine.load to memref.load
        SmallVector<Value> indices;
        for (auto idx : loadOp.getMapOperands()) {
          indices.push_back(mapping.lookupOrDefault(idx));
        }
        auto newLoad = bodyBuilder.create<memref::LoadOp>(loc, loadOp.getMemref(), indices);
        mapping.map(loadOp.getResult(), newLoad.getResult());
      } else if (auto storeOp = dyn_cast<affine::AffineStoreOp>(op)) {
        // Convert affine.store to memref.store
        SmallVector<Value> indices;
        for (auto idx : storeOp.getMapOperands()) {
          indices.push_back(mapping.lookupOrDefault(idx));
        }
        bodyBuilder.create<memref::StoreOp>(
            loc, mapping.lookupOrDefault(storeOp.getValue()),
            storeOp.getMemref(), indices);
      } else {
        bodyBuilder.clone(op, mapping);
      }
    }

    affineLoop.erase();
    return success();
  }

  std::optional<int64_t> getConstantBound(AffineForOp loop, bool isLower) {
    AffineMap map = isLower ? loop.getLowerBoundMap() : loop.getUpperBoundMap();

    if (map.getNumResults() != 1 || map.getNumInputs() != 0) {
      return std::nullopt;
    }

    auto expr = map.getResult(0);
    if (auto constExpr = dyn_cast<AffineConstantExpr>(expr)) {
      return constExpr.getValue();
    }

    return std::nullopt;
  }

  StringRef getArgument() const final { return "parallelize-outer-loops"; }

  StringRef getDescription() const final {
    return "Convert outer matmul loops to scf.parallel for OpenMP parallelization";
  }
};

std::unique_ptr<Pass> createParallelizeOuterLoopsPass() {
  return std::make_unique<ParallelizeOuterLoopsPass>();
}

} // namespace nova
} // namespace mlir
