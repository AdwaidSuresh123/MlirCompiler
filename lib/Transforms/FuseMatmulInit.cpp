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
    
    // K_O should be the child of J_I
    AffineForOp KOuter = getSingleChildAffineFor(JInner);
    if (!KOuter) {
      llvm::errs() << "Could not find K_O loop\n";
      return;
    }
    
    llvm::errs() << "Successfully navigated loop structure\n";

    Value I_inner_iv = IInner.getInductionVar();
    Value J_inner_iv = JInner.getInductionVar();
    
    // Insert the zero-store operation BEFORE the K_O loop
    OpBuilder builder(JInner.getBody(), JInner.getBody()->begin());
    SmallVector<Value> mapOperands = {I_inner_iv, J_inner_iv};
    
    Value cst = zeroStore.getValue();

    builder.create<AffineStoreOp>(
        zeroStore.getLoc(),
        cst, 
        resultBuffer, 
        zeroStore.getMap(), 
        mapOperands
    );

    llvm::errs() << "Inserted initialization store\n";

    // Erase the original initialization loop 
    initLoop.erase();

    llvm::errs() << "=== Fusion complete! ===\n";
  }

private:
  AffineForOp getSingleChildAffineFor(AffineForOp loop) {
    auto block = loop.getBody();
    for (Operation &op : *block) {
        if (auto childLoop = dyn_cast<AffineForOp>(op)) {
            return childLoop;
        }
    }
    return nullptr;
  }

  // Check if a loop is the simple zero initialization loop
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
  
  // Check if loop has matmul computation pattern (multiply + add)
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
  
  // Finds the single zero-store instruction in the initialization loop nest
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

  // Check if the buffer is used as an accumulator in the compute loop
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
    return "Fuse matmul initialization store into tiled computation loop.";
  }
};

std::unique_ptr<mlir::Pass> createFuseMatmulInit() {
  return std::make_unique<FuseMatmulInitPass>();
}

} // namespace nova
} // namespace mlir