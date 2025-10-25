#include "Compiler/Transforms/FuseMatmulInit.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Pass/Pass.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/Passes.h"
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
    
    llvm::errs() << "=== FuseMatmulInit Pass Starting on function: " 
                 << func.getName() << " ===\n";
    
    // Collect all top-level affine.for loops
    SmallVector<AffineForOp, 2> topLevelLoops;
    for (auto &op : func.getBody().front()) {
      if (auto forOp = dyn_cast<AffineForOp>(op)) {
        topLevelLoops.push_back(forOp);
      }
    }
    
    llvm::errs() << "Found " << topLevelLoops.size() << " top-level loops\n";
    
    // Find initialization and computation loops
    AffineForOp initLoop = nullptr;
    AffineForOp computeLoop = nullptr;
    
    for (auto loop : topLevelLoops) {
      if (isZeroInitializationLoop(loop)) {
        initLoop = loop;
        llvm::errs() << "Found initialization loop\n";
      } else if (hasMatmulPattern(loop)) {
        computeLoop = loop;
        llvm::errs() << "Found computation loop\n";
      }
    }

    if (!initLoop) {
      llvm::errs() << "No initialization loop found - skipping\n";
      return;
    }
    
    if (!computeLoop) {
      llvm::errs() << "No computation loop found - skipping\n";
      return;
    }
    
    // Get the zero store and buffer
    AffineStoreOp zeroStore = findZeroStore(initLoop);
    Value resultBuffer = zeroStore ? zeroStore.getMemRef() : Value{};
    if (!zeroStore || !resultBuffer) {
      llvm::errs() << "Could not find zero store or result buffer\n";
      return;
    }

    if (!usesBufferAsAccumulator(computeLoop, resultBuffer)) {
      llvm::errs() << "Buffer not used as accumulator in compute loop\n";
      return;
    }
    
    llvm::errs() << "Buffer is used as accumulator - proceeding with fusion\n";
    
    // Navigate the loop structure: I_O -> J_O -> I_I -> J_I -> K_O -> K_I
    AffineForOp IOuter = computeLoop;  // computeLoop IS I_O
    AffineForOp JOuter = getSingleChildAffineFor(IOuter); 
    if (!JOuter) {
      llvm::errs() << "Could not find J_O loop\n";
      return;
    }
    
    AffineForOp IInner = getSingleChildAffineFor(JOuter);
    if (!IInner) {
      llvm::errs() << "Could not find I_I loop\n";
      return;
    }
    
    AffineForOp JInner = getSingleChildAffineFor(IInner); 
    if (!JInner) {
      llvm::errs() << "Could not find J_I loop\n";
      return;
    }
    
    // K_O should be the child of J_I - this is our reduction loop
    AffineForOp KOuter = getSingleChildAffineFor(JInner);
    if (!KOuter) {
      llvm::errs() << "Could not find K_O loop\n";
      return;
    }
    
    // K_I is the innermost loop (inside K_O)
    AffineForOp KInner = getSingleChildAffineFor(KOuter);
    if (!KInner) {
      llvm::errs() << "Could not find K_I loop\n";
      return;
    }
    
    llvm::errs() << "Successfully navigated loop structure\n";

    // Now transform to simple scalar accumulation
    if (failed(transformToScalarAccumulation(KOuter, KInner, resultBuffer, IInner, JInner))) {
      llvm::errs() << "Failed to transform to scalar accumulation\n";
      signalPassFailure();
      return;
    }

    // Erase the original initialization loop 
    initLoop.erase();

    llvm::errs() << "=== Fusion complete! ===\n";
  }

private:
  
  private:
  LogicalResult transformToScalarAccumulation(AffineForOp kOuter, AffineForOp kInner, 
                                              Value resultBuffer, AffineForOp iLoop, 
                                              AffineForOp jLoop) {
    OpBuilder builder(kOuter);
    Location loc = kOuter.getLoc();
    
    Value iIV = iLoop.getInductionVar();
    Value jIV = jLoop.getInductionVar();
    
    // Create initial zero value
    auto zeroAttr = builder.getFloatAttr(builder.getF32Type(), 0.0);
    Value initZero = builder.create<arith::ConstantOp>(loc, zeroAttr);
    
    // Clone bounds
    SmallVector<Value> outerLowerBounds(kOuter.getLowerBoundOperands().begin(),
                                         kOuter.getLowerBoundOperands().end());
    SmallVector<Value> outerUpperBounds(kOuter.getUpperBoundOperands().begin(),
                                         kOuter.getUpperBoundOperands().end());
    AffineMap outerLowerMap = kOuter.getLowerBoundMap();
    AffineMap outerUpperMap = kOuter.getUpperBoundMap();
    int64_t stepOuter = kOuter.getStep().getSExtValue();
    
    SmallVector<Value> innerLowerBounds(kInner.getLowerBoundOperands().begin(),
                                         kInner.getLowerBoundOperands().end());
    SmallVector<Value> innerUpperBounds(kInner.getUpperBoundOperands().begin(),
                                         kInner.getUpperBoundOperands().end());
    AffineMap innerLowerMap = kInner.getLowerBoundMap();
    AffineMap innerUpperMap = kInner.getUpperBoundMap();
    int64_t stepInner = kInner.getStep().getSExtValue();
    
    // Create K_O loop with iter_args
    auto newKOuter = builder.create<AffineForOp>(
        loc,
        outerLowerBounds,
        outerLowerMap,
        outerUpperBounds,
        outerUpperMap,
        stepOuter,
        ValueRange{initZero});
    
    Value accOuter = newKOuter.getRegionIterArgs()[0];
    
    // Build K_O body
    OpBuilder outerBodyBuilder(newKOuter.getBody(), newKOuter.getBody()->begin());
    IRMapping outerMapping;
    outerMapping.map(kOuter.getInductionVar(), newKOuter.getInductionVar());
    
    // Map inner loop bounds
    for (auto operand : innerLowerBounds) {
      if (operand == kOuter.getInductionVar()) {
        outerMapping.map(operand, newKOuter.getInductionVar());
      }
    }
    for (auto operand : innerUpperBounds) {
      if (operand == kOuter.getInductionVar()) {
        outerMapping.map(operand, newKOuter.getInductionVar());
      }
    }
    
    SmallVector<Value> mappedInnerLower;
    for (auto v : innerLowerBounds) {
      mappedInnerLower.push_back(outerMapping.lookupOrDefault(v));
    }
    SmallVector<Value> mappedInnerUpper;
    for (auto v : innerUpperBounds) {
      mappedInnerUpper.push_back(outerMapping.lookupOrDefault(v));
    }
    
    // Create K_I loop WITH iter_args to properly yield the accumulator
    auto newKInner = outerBodyBuilder.create<AffineForOp>(
        loc,
        mappedInnerLower,
        innerLowerMap,
        mappedInnerUpper,
        innerUpperMap,
        stepInner,
        ValueRange{accOuter});  // Pass accumulator from outer
    
    Value accInner = newKInner.getRegionIterArgs()[0];
    
    // Build K_I body
    OpBuilder innerBodyBuilder(newKInner.getBody(), newKInner.getBody()->begin());
    IRMapping innerMapping;
    innerMapping.map(kInner.getInductionVar(), newKInner.getInductionVar());
    innerMapping.map(kOuter.getInductionVar(), newKOuter.getInductionVar());
    
    Value currentAcc = accInner;
    
    // Clone operations
    for (Operation &op : kInner.getBody()->without_terminator()) {
      
      if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
        if (loadOp.getMemRef() == resultBuffer) {
          innerMapping.map(loadOp.getResult(), currentAcc);
          continue;
        }
      }
      
      if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
        if (storeOp.getMemRef() == resultBuffer) {
          currentAcc = innerMapping.lookupOrDefault(storeOp.getValue());
          continue;
        }
      }
      
      Operation *cloned = innerBodyBuilder.clone(op, innerMapping);
      for (auto [oldResult, newResult] : llvm::zip(op.getResults(), cloned->getResults())) {
        innerMapping.map(oldResult, newResult);
      }
    }
    
    // CRITICAL: Yield the accumulator from the inner loop
    innerBodyBuilder.create<AffineYieldOp>(loc, ValueRange{currentAcc});
    
    // Yield from outer loop
    outerBodyBuilder.setInsertionPointAfter(newKInner);
    outerBodyBuilder.create<AffineYieldOp>(loc, ValueRange{newKInner.getResult(0)});
    
    // Store final result
    builder.setInsertionPointAfter(newKOuter);
    builder.create<AffineStoreOp>(
        loc,
        newKOuter.getResult(0),
        resultBuffer,
        builder.getMultiDimIdentityMap(2),
        ValueRange{iIV, jIV});
    
    kOuter.erase();
    
    llvm::errs() << "Transformed to simple scalar accumulation pattern\n";
    return success();
  }

  AffineForOp getSingleChildAffineFor(AffineForOp loop) {
    auto block = loop.getBody();
    for (Operation &op : *block) {
        if (auto childLoop = dyn_cast<AffineForOp>(op)) {
            return childLoop;
        }
    }
    return nullptr;
  }

  bool isZeroInitializationLoop(AffineForOp loop) {
    bool foundConstantStore = false;
    loop.walk([&](AffineStoreOp store) {
      if (auto constOp = store.getValue().getDefiningOp<arith::ConstantOp>()) {
        if (auto floatAttr = dyn_cast<FloatAttr>(constOp.getValue())) {
          if (floatAttr.getValueAsDouble() == 0.0) {
            foundConstantStore = true;
            return WalkResult::interrupt();
          }
        }
      }
      return WalkResult::advance();
    });
    return foundConstantStore;
  }
  
  bool hasMatmulPattern(AffineForOp loop) {
    bool hasMul = false;
    bool hasAdd = false;
    
    loop.walk([&](Operation *op) {
      if (isa<arith::MulFOp>(op)) hasMul = true;
      if (isa<arith::AddFOp>(op)) hasAdd = true;
      if (hasMul && hasAdd) return WalkResult::interrupt();
      return WalkResult::advance();
    });
    
    return hasMul && hasAdd;
  }
  
  AffineStoreOp findZeroStore(AffineForOp loop) {
    AffineStoreOp zeroStore = nullptr;
    loop.walk([&](AffineStoreOp store) {
        if (auto constOp = store.getValue().getDefiningOp<arith::ConstantOp>()) {
            if (auto floatAttr = dyn_cast<FloatAttr>(constOp.getValue())) {
                if (floatAttr.getValueAsDouble() == 0.0) {
                    zeroStore = store;
                    return WalkResult::interrupt();
                }
            }
        }
        return WalkResult::advance();
    });
    return zeroStore;
  }

  bool usesBufferAsAccumulator(AffineForOp loop, Value buffer) {
    bool found = false;
    loop.walk([&](AffineLoadOp load) {
      if (load.getMemRef() == buffer) {
        for (auto user : load->getUsers()) {
          if (isa<arith::AddFOp>(user)) {
            found = true;
            return WalkResult::interrupt();
          }
        }
      }
      return WalkResult::advance();
    });
    return found;
  }
  
  StringRef getArgument() const final { return "fuse-matmul-init"; }
  
  StringRef getDescription() const final {
    return "Fuse matmul initialization with computation using simple scalar accumulation.";
  }
};

std::unique_ptr<mlir::Pass> createFuseMatmulInit() {
  return std::make_unique<FuseMatmulInitPass>();
}

} // namespace nova
} // namespace mlir