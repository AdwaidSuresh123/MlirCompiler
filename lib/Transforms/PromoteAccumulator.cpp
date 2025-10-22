#include "Compiler/Transforms/PromoteAccumulator.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Pass/Pass.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Dominance.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "promote-accumulator"

using namespace mlir;
using namespace mlir::affine;

namespace mlir {
namespace nova {

struct PromoteAccumulatorPass 
    : public PassWrapper<PromoteAccumulatorPass, OperationPass<func::FuncOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(PromoteAccumulatorPass)
  
  void runOnOperation() override {
    auto func = getOperation();
    
    llvm::errs() << "=== PromoteAccumulator Pass Starting ===\n";
    
    // Find patterns: init store followed by reduction loop
    SmallVector<std::pair<AffineStoreOp, AffineForOp>> patterns;
    
    func.walk([&](AffineForOp outerLoop) {
      // Look for pattern in this loop's body
      auto *body = outerLoop.getBody();
      
      for (auto it = body->begin(); it != body->end(); ++it) {
        // Look for: store init, then for loop
        if (auto storeOp = dyn_cast<AffineStoreOp>(*it)) {
          // Check if this is an initialization store (constant value)
          if (!isa_and_nonnull<arith::ConstantOp>(storeOp.getValue().getDefiningOp())) {
            continue;
          }
          
          // Look for the next for loop
          auto nextIt = std::next(it);
          if (nextIt != body->end()) {
            if (auto forOp = dyn_cast<AffineForOp>(*nextIt)) {
              // Check if this for loop uses the same memref as accumulator
              Value memref = storeOp.getMemRef();
              SmallVector<Value> storeIndices(storeOp.getIndices().begin(), 
                                              storeOp.getIndices().end());
              if (isAccumulatorLoop(forOp, memref, storeIndices)) {
                patterns.push_back({storeOp, forOp});
                llvm::errs() << "Found accumulator pattern!\n";
              }
            }
          }
        }
      }
    });
    
    llvm::errs() << "Found " << patterns.size() << " accumulator patterns\n";
    
    // Transform each pattern
    for (auto [initStore, reductionLoop] : patterns) {
      if (failed(promoteAccumulator(initStore, reductionLoop))) {
        llvm::errs() << "Failed to promote accumulator\n";
        signalPassFailure();
        return;
      }
    }
    
    llvm::errs() << "=== PromoteAccumulator Pass Complete ===\n";
  }

private:
  
  // Check if a loop uses a memref location as an accumulator
  bool isAccumulatorLoop(AffineForOp loop, Value memref, 
                         ArrayRef<Value> indices) {
    bool hasLoad = false;
    bool hasStore = false;
    bool hasAddF = false;
    
    loop.walk([&](Operation *op) {
      if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
        if (loadOp.getMemRef() == memref) {
          SmallVector<Value> loadIndices(loadOp.getIndices().begin(), 
                                         loadOp.getIndices().end());
          if (sameIndices(loadIndices, indices)) {
            hasLoad = true;
            
            // Check if load is used in an addf
            for (auto user : loadOp->getUsers()) {
              if (isa<arith::AddFOp>(user)) {
                hasAddF = true;
              }
            }
          }
        }
      }
      
      if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
        if (storeOp.getMemRef() == memref) {
          SmallVector<Value> storeIndices(storeOp.getIndices().begin(), 
                                          storeOp.getIndices().end());
          if (sameIndices(storeIndices, indices)) {
            hasStore = true;
          }
        }
      }
    });
    
    return hasLoad && hasStore && hasAddF;
  }
  
  // Check if two index lists refer to the same location
  bool sameIndices(ArrayRef<Value> indices1, 
                   ArrayRef<Value> indices2) {
    if (indices1.size() != indices2.size()) return false;
    
    for (size_t i = 0; i < indices1.size(); ++i) {
      if (indices1[i] != indices2[i]) return false;
    }
    return true;
  }
  
  // Transform: init + loop with load-add-store -> loop with iter_args
  LogicalResult promoteAccumulator(AffineStoreOp initStore, 
                                   AffineForOp reductionLoop) {
    
    llvm::errs() << "Promoting accumulator to registers...\n";
    
    OpBuilder builder(reductionLoop);
    Location loc = reductionLoop.getLoc();
    
    Value memref = initStore.getMemRef();
    SmallVector<Value> indices(initStore.getIndices().begin(), 
                               initStore.getIndices().end());
    Value initValue = initStore.getValue();
    
    // Get step value as int64_t
    int64_t step = reductionLoop.getStep().getSExtValue();
    
    // Create new loop with iter_args
    auto newLoop = builder.create<AffineForOp>(
        loc,
        reductionLoop.getLowerBoundOperands(),
        reductionLoop.getLowerBoundMap(),
        reductionLoop.getUpperBoundOperands(),
        reductionLoop.getUpperBoundMap(),
        step,
        ValueRange{initValue});  // iter_arg with init value
    
    // Get the accumulator block argument
    Value accArg = newLoop.getRegionIterArgs()[0];
    
    // Build new loop body
    Block *oldBody = reductionLoop.getBody();
    Block *newBody = newLoop.getBody();
    OpBuilder bodyBuilder(newBody, newBody->begin());
    
    // Map old IV to new IV
    IRMapping mapping;
    mapping.map(reductionLoop.getInductionVar(), newLoop.getInductionVar());
    
    // Track the accumulated value through the loop
    Value currentAcc = accArg;
    
    // Clone operations, replacing loads with accumulator
    for (Operation &op : oldBody->without_terminator()) {
      
      // Skip loads from the accumulator location
      if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
        if (loadOp.getMemRef() == memref) {
          SmallVector<Value> loadIndices(loadOp.getIndices().begin(), 
                                         loadOp.getIndices().end());
          if (sameIndices(loadIndices, indices)) {
            // Map this load to the current accumulator value
            mapping.map(loadOp.getResult(), currentAcc);
            continue;
          }
        }
      }
      
      // Skip stores to the accumulator location (we'll handle at the end)
      if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
        if (storeOp.getMemRef() == memref) {
          SmallVector<Value> storeIndices(storeOp.getIndices().begin(), 
                                          storeOp.getIndices().end());
          if (sameIndices(storeIndices, indices)) {
            // This should be storing the new accumulator value
            // Update currentAcc to be the stored value
            currentAcc = mapping.lookupOrDefault(storeOp.getValue());
            continue;
          }
        }
      }
      
      // Clone other operations
      Operation *cloned = bodyBuilder.clone(op, mapping);
      
      // Update mapping for results
      for (auto [oldResult, newResult] : 
           llvm::zip(op.getResults(), cloned->getResults())) {
        mapping.map(oldResult, newResult);
      }
    }
    
    // Yield the final accumulator value
    bodyBuilder.create<AffineYieldOp>(loc, ValueRange{currentAcc});
    
    // Store the final result after the loop
    builder.setInsertionPointAfter(newLoop);
    builder.create<AffineStoreOp>(
        loc,
        newLoop.getResult(0),  // The accumulated value
        memref,
        initStore.getMap(),
        indices);
    
    // Remove the old initialization store and loop
    reductionLoop.erase();
    initStore.erase();
    
    llvm::errs() << "Successfully promoted accumulator!\n";
    
    return success();
  }
  
  StringRef getArgument() const final { return "promote-accumulator"; }
  
  StringRef getDescription() const final {
    return "Promote memory-based accumulators to register-based iter_args";
  }
};

std::unique_ptr<mlir::Pass> createPromoteAccumulator() {
  return std::make_unique<PromoteAccumulatorPass>();
}

} // namespace nova
} // namespace mlir