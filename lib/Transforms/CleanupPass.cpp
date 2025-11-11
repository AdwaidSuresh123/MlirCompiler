#include "Compiler/Transforms/CleanupPass.h"

#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/UB/IR/UBOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::compiler;

namespace {

// Pattern to replace ub.poison with llvm.mlir.undef
struct PoisonToUndefPattern : public OpRewritePattern<ub::PoisonOp> {
  using OpRewritePattern<ub::PoisonOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ub::PoisonOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<LLVM::UndefOp>(op, op.getType());
    return success();
  }
};

// Pattern to remove identity unrealized conversion casts
struct RemoveIdentityCastPattern 
    : public OpRewritePattern<UnrealizedConversionCastOp> {
  using OpRewritePattern<UnrealizedConversionCastOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(UnrealizedConversionCastOp op,
                                PatternRewriter &rewriter) const override {
    if (op.getInputs().size() != 1 || op.getResults().size() != 1)
      return failure();
    
    Value input = op.getInputs()[0];
    if (input.getType() != op.getResult(0).getType())
      return failure();
    
    rewriter.replaceOp(op, input);
    return success();
  }
};

struct CleanupPass : public PassWrapper<CleanupPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CleanupPass)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<LLVM::LLVMDialect, ub::UBDialect>();
  }

  void runOnOperation() override {
    MLIRContext *ctx = &getContext();
    RewritePatternSet patterns(ctx);
    
    // Add cleanup patterns
    patterns.add<PoisonToUndefPattern, RemoveIdentityCastPattern>(ctx);
    
    // Apply patterns greedily
    if (failed(applyPatternsGreedily(getOperation(),
                                  std::move(patterns)))) {
      signalPassFailure();
    }
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