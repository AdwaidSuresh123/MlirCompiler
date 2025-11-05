#include "Compiler/Transforms/FuseMatmulBias.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::linalg;

namespace {

// Pattern to fuse: matmul + add (bias)
struct FuseMatmulBiasPattern : public OpRewritePattern<GenericOp> {
  using OpRewritePattern<GenericOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GenericOp addOp,
                                  PatternRewriter &rewriter) const override {
    // Check if this is an elementwise add
    if (!isElementwise(addOp))
      return failure();

    // Get the input to the add
    Value addInput = addOp.getDpsInputOperand(0)->get();

    // Check if input comes from a matmul
    auto matmulOp = addInput.getDefiningOp<GenericOp>();
    if (!matmulOp || !isMatmul(matmulOp))
      return failure();

    // Check that matmul has only one use (this add)
    if (!matmulOp->hasOneUse())
      return failure();

    llvm::errs() << "Found fusible matmul + add pattern!\n";

    // Get the bias input (the second input to the add)
    Value bias = addOp.getDpsInputOperand(1)->get();

    // Get matmul inputs
    Value A = matmulOp.getDpsInputOperand(0)->get();
    Value B = matmulOp.getDpsInputOperand(1)->get();

    // Get the output for the fused operation
    Value output = addOp.getDpsInitOperand(0)->get();

    // Get location for the new operation
    Location loc = addOp.getLoc();

    // Create the fused matmul+bias operation
    // The fused op computes: C[i,j] = sum_k(A[i,k] * B[k,j]) + bias[i,j]

    auto matmulType = cast<RankedTensorType>(matmulOp.getResult(0).getType());
    SmallVector<AffineMap> indexingMaps;
    SmallVector<utils::IteratorType> iteratorTypes;

    // Build affine maps for: (i,j,k) -> A[i,k], B[k,j], bias[i,j], C[i,j]
    auto context = rewriter.getContext();
    indexingMaps.push_back(AffineMap::get(3, 0,
        {rewriter.getAffineDimExpr(0), rewriter.getAffineDimExpr(2)}, context)); // A[i,k]
    indexingMaps.push_back(AffineMap::get(3, 0,
        {rewriter.getAffineDimExpr(2), rewriter.getAffineDimExpr(1)}, context)); // B[k,j]
    indexingMaps.push_back(AffineMap::get(3, 0,
        {rewriter.getAffineDimExpr(0), rewriter.getAffineDimExpr(1)}, context)); // bias[i,j]
    indexingMaps.push_back(AffineMap::get(3, 0,
        {rewriter.getAffineDimExpr(0), rewriter.getAffineDimExpr(1)}, context)); // C[i,j]

    // Iterator types: parallel(i), parallel(j), reduction(k)
    iteratorTypes = {utils::IteratorType::parallel,
                     utils::IteratorType::parallel,
                     utils::IteratorType::reduction};

    // Create the fused generic op
    auto fusedOp = rewriter.create<GenericOp>(
        loc,
        matmulType,
        ValueRange{A, B, bias},  // inputs
        ValueRange{output},       // outputs
        indexingMaps,
        iteratorTypes,
        [&](OpBuilder &b, Location loc, ValueRange args) {
          // args[0] = A[i,k], args[1] = B[k,j], args[2] = bias[i,j], args[3] = C[i,j]
          Value mul = b.create<arith::MulFOp>(loc, args[0], args[1]);
          Value partialSum = b.create<arith::AddFOp>(loc, args[3], mul);
          Value withBias = b.create<arith::AddFOp>(loc, partialSum, args[2]);
          b.create<linalg::YieldOp>(loc, withBias);
        }
    );

    llvm::errs() << "Successfully fused matmul + bias into single operation!\n";

    // Replace the add operation with the fused operation
    rewriter.replaceOp(addOp, fusedOp.getResult(0));

    // The matmul op will be automatically removed since it has no more uses

    return success();
  }

private:
  bool isElementwise(GenericOp op) const {
    // Check if all loops are parallel
    return llvm::all_of(op.getIteratorTypesArray(), [](utils::IteratorType it) {
      return it == utils::IteratorType::parallel;
    });
  }

  bool isMatmul(GenericOp op) const {
    auto iterators = op.getIteratorTypesArray();
    // Matmul has 2 parallel + 1 reduction dimension
    if (iterators.size() != 3)
      return false;

    return iterators[0] == utils::IteratorType::parallel &&
           iterators[1] == utils::IteratorType::parallel &&
           iterators[2] == utils::IteratorType::reduction;
  }
};

// The pass that applies the fusion pattern
struct FuseMatmulBiasPass
    : public PassWrapper<FuseMatmulBiasPass, OperationPass<func::FuncOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FuseMatmulBiasPass)

  void runOnOperation() override {
    auto func = getOperation();

    llvm::errs() << "=== Running FuseMatmulBias Pass ===\n";

    // Apply the pattern
    RewritePatternSet patterns(&getContext());
    patterns.add<FuseMatmulBiasPattern>(&getContext());

    if (failed(applyPatternsAndFoldGreedily(func, std::move(patterns)))) {
      signalPassFailure();
    }

    llvm::errs() << "=== FuseMatmulBias Pass Complete ===\n";
  }

  StringRef getArgument() const final { return "fuse-matmul-bias"; }

  StringRef getDescription() const final {
    return "Fuse matmul + bias add into a single operation";
  }
};

} // namespace

namespace mlir {
namespace nova {

std::unique_ptr<Pass> createFuseMatmulBiasPass() {
  return std::make_unique<FuseMatmulBiasPass>();
}

} // namespace nova
} // namespace mlir
