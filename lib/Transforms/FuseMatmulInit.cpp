//===----------------------------------------------------------------------===//
// FuseMatmulInit.cpp - Fuse initialization with matmul computation
//===----------------------------------------------------------------------===//

#include "Compiler/Transforms/FuseMatmulInit.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"  // ADD THIS!
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Pass/Pass.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Dominance.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "fuse-matmul-init"

using namespace mlir;
using namespace mlir::affine;

namespace mlir {
namespace nova {

struct FuseMatmulInitPass 
    : public PassWrapper<FuseMatmulInitPass, OperationPass<func::FuncOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FuseMatmulInitPass)
  
  void runOnOperation() override {
    auto func = getOperation();
    
    // Collect all top-level affine loops
    SmallVector<AffineForOp> topLevelLoops;
    func.walk([&](AffineForOp loop) {
      // Only top-level loops (no parent affine.for)
      if (!loop->getParentOfType<AffineForOp>()) {
        topLevelLoops.push_back(loop);
      }
    });
    
    if (topLevelLoops.size() < 2) {
      return; // Need at least 2 loops to fuse
    }
    
    // Pattern: First loop is initialization, second is computation
    AffineForOp initLoop = topLevelLoops[0];
    AffineForOp computeLoop = topLevelLoops[1];
    
    // Verify this is the init+matmul pattern
    if (!isInitializationLoop(initLoop)) {
      LLVM_DEBUG(llvm::dbgs() << "First loop is not initialization\n");
      return;
    }
    
    if (!hasMatchingBounds(initLoop, computeLoop)) {
      LLVM_DEBUG(llvm::dbgs() << "Loops don't have matching bounds\n");
      return;
    }
    
    // Find the buffer being initialized
    Value buffer = findInitializedBuffer(initLoop);
    if (!buffer) {
      LLVM_DEBUG(llvm::dbgs() << "Could not find initialized buffer\n");
      return;
    }
    
    LLVM_DEBUG(llvm::dbgs() << "Fusing initialization with computation\n");
    
    // Replace loads from buffer with zero in the innermost loop
    replaceInitialLoadsWithZero(computeLoop, buffer);
    
    // Erase the initialization loop
    initLoop.erase();
    
    LLVM_DEBUG(llvm::dbgs() << "Fusion complete\n");
  }
  
private:
  /// Check if loop stores constant values (initialization pattern)
  bool isInitializationLoop(AffineForOp loop) {
    bool foundConstantStore = false;
    loop.walk([&](AffineStoreOp store) {
      if (store.getValue().getDefiningOp<arith::ConstantOp>()) {
        foundConstantStore = true;
      }
    });
    return foundConstantStore;
  }
  
  /// Check if two loops have matching iteration bounds
  bool hasMatchingBounds(AffineForOp loop1, AffineForOp loop2) {
    // Check outer loops match
    if (loop1.getConstantLowerBound() != loop2.getConstantLowerBound())
      return false;
    if (loop1.getConstantUpperBound() != loop2.getConstantUpperBound())
      return false;
    if (loop1.getStepAsInt() != loop2.getStepAsInt())
      return false;
    
    return true;
  }
  
  /// Find which buffer is being initialized
  Value findInitializedBuffer(AffineForOp loop) {
    Value buffer;
    loop.walk([&](AffineStoreOp store) {
      if (!buffer) {
        buffer = store.getMemRef();
      }
    });
    return buffer;
  }
  
  /// Replace the first load from buffer in inner loop with zero
  void replaceInitialLoadsWithZero(AffineForOp outerLoop, Value buffer) {
    // Walk to find the innermost k-loop (reduction loop)
    outerLoop.walk([&](AffineForOp kLoop) {
      // Check if this looks like the k-loop (has step 8)
      if (kLoop.getStepAsInt() != 8)
        return;
      
      // Inside the k-loop, find the first load from buffer
      bool foundFirstLoad = false;
      kLoop.walk([&](AffineLoadOp load) {
        if (load.getMemRef() != buffer)
          return;
        
        if (foundFirstLoad)
          return; // Skip subsequent loads
        
        // This is the accumulator initialization - replace with zero
        OpBuilder builder(load);
        auto zeroType = cast<FloatType>(load.getType());
        auto zero = builder.create<arith::ConstantOp>(
            load.getLoc(),
            builder.getFloatAttr(zeroType, 0.0));
        
        // Replace only uses in the same block (for accumulator init)
        for (auto &use : llvm::make_early_inc_range(load->getUses())) {
          if (auto addOp = dyn_cast<arith::AddFOp>(use.getOwner())) {
            // This is the accumulator - replace load with zero
            use.set(zero);
            foundFirstLoad = true;
          }
        }
      });
    });
  }
  
  StringRef getArgument() const final { return "fuse-matmul-init"; }
  
  StringRef getDescription() const final {
    return "Fuse matmul initialization loop with computation loop";
  }
};

} // namespace nova
} // namespace mlir

// Factory function
std::unique_ptr<mlir::Pass> mlir::nova::createFuseMatmulInit() {
  return std::make_unique<mlir::nova::FuseMatmulInitPass>();
}