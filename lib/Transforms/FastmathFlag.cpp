#include "Compiler/Transforms/FastmathFlag.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/Pass/Pass.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "fastmath-flag"

using namespace mlir;
using namespace mlir::arith;

namespace mlir {
namespace nova {

struct FastmathFlagPass 
    : public PassWrapper<FastmathFlagPass, OperationPass<func::FuncOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FastmathFlagPass)
  
  void runOnOperation() override {
    auto func = getOperation();
    
    llvm::errs() << "=== FastmathFlag Pass Starting on function: " 
                 << func.getName() << " ===\n";
    
    unsigned mulCount = 0;
    unsigned addCount = 0;
    unsigned divCount = 0;
    
    // Walk through all operations in the function
    func.walk([&](Operation *op) {
      // Handle floating-point multiply
      if (auto mulOp = dyn_cast<MulFOp>(op)) {
        FastMathFlags flags = mulOp.getFastmath();
        if (!bitEnumContainsAny(flags, FastMathFlags::contract)) {
          addContractFlag(mulOp);
          mulCount++;
        }
      }
      // Handle floating-point add
      else if (auto addOp = dyn_cast<AddFOp>(op)) {
        FastMathFlags flags = addOp.getFastmath();
        if (!bitEnumContainsAny(flags, FastMathFlags::contract)) {
          addContractFlag(addOp);
          addCount++;
        }
      }
      // Handle floating-point subtract (can also benefit from FMA: a - b*c)
      else if (auto subOp = dyn_cast<SubFOp>(op)) {
        FastMathFlags flags = subOp.getFastmath();
        if (!bitEnumContainsAny(flags, FastMathFlags::contract)) {
          addContractFlag(subOp);
          addCount++;
        }
      }
      // Optionally handle division for other optimizations
      else if (auto divOp = dyn_cast<DivFOp>(op)) {
        FastMathFlags flags = divOp.getFastmath();
        if (!bitEnumContainsAny(flags, FastMathFlags::contract)) {
          addContractFlag(divOp);
          divCount++;
        }
      }
    });
    
    llvm::errs() << "Added fastmath<contract> to:\n"
                 << "  - " << mulCount << " mulf operations\n"
                 << "  - " << addCount << " addf/subf operations\n"
                 << "  - " << divCount << " divf operations\n"
                 << "=== FastmathFlag Pass Complete ===\n";
  }

private:
  template<typename OpType>
  void addContractFlag(OpType op) {
    OpBuilder builder(op);
    
    // Get existing fastmath flags (always returns a value, not optional)
    FastMathFlags flags = op.getFastmath();
    
    // Add the contract flag
    flags = flags | FastMathFlags::contract;
    
    // Create a new operation with the updated flags
    auto newOp = builder.create<OpType>(
        op.getLoc(),
        op.getResult().getType(),
        op.getLhs(),
        op.getRhs(),
        flags);
    
    // Replace all uses of the old operation with the new one
    op.getResult().replaceAllUsesWith(newOp.getResult());
    
    // Erase the old operation
    op.erase();
  }
  
  StringRef getArgument() const final { return "fastmath-flag"; }
  
  StringRef getDescription() const final {
    return "Add fastmath<contract> flags to floating-point arithmetic operations "
           "to enable FMA fusion and other optimizations.";
  }
};

std::unique_ptr<mlir::Pass> createFastmathFlagPass() {
  return std::make_unique<FastmathFlagPass>();
}

} // namespace nova
} // namespace mlir