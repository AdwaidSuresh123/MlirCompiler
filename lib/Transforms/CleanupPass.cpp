#include "Compiler/Transforms/CleanupPass.h"

#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::compiler;

namespace {

struct CleanupPass : public PassWrapper<CleanupPass, OperationPass<ModuleOp>> {
  void runOnOperation() override {
    ModuleOp module = getOperation();
    
    // Remove ub.poison operations by name matching
    module.walk([&](Operation *op) {
      StringRef opName = op->getName().getStringRef();
      
      // Remove any operation with "ub.poison" in its name
      if (opName.contains("ub.poison")) {
        OpBuilder builder(op);
        Value undef = builder.create<LLVM::UndefOp>(op->getLoc(), op->getResult(0).getType());
        op->getResult(0).replaceAllUsesWith(undef);
        op->erase();
        return;
      }
      
      // Remove unnecessary conversion casts
      if (auto castOp = dyn_cast<UnrealizedConversionCastOp>(op)) {
        if (castOp.getInputs().size() == 1 && castOp.getResults().size() == 1) {
          Value input = castOp.getInputs()[0];
          if (input.getType() == castOp.getResult(0).getType()) {
            castOp.getResult(0).replaceAllUsesWith(input);
            castOp->erase();
          }
        }
      }
    });
  }
  
  StringRef getArgument() const final { return "cleanup"; }
  StringRef getDescription() const final { 
    return "Clean up ub.poison and unnecessary casts"; 
  }
};

} // namespace

std::unique_ptr<Pass> mlir::compiler::createCleanupPass() {
  return std::make_unique<CleanupPass>();
}