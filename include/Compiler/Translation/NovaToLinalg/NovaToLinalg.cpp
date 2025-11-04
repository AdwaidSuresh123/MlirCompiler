#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"

#include "Compiler/Translation/NovaToLinalg/NovaToLinalg.h"
#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/NovaDialect.h"

namespace mlir {
namespace nova {

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//
struct NovaAddOpLowering : public OpConversionPattern<nova::AddOp> {
  using OpConversionPattern<nova::AddOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::AddOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    // Get operands
    auto operands = adaptor.getOperands();
    
    // Verify we have exactly 2 operands
    if (operands.size() != 2) {
      return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
    }
    
    Value lhs = operands[0];
    Value rhs = operands[1];
    
    // Get the result type
    Type resultType = op.getType();
    
    // Verify result is a tensor type
    auto tensorType = llvm::dyn_cast<RankedTensorType>(resultType);
    if (!tensorType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result type");
    }
    
    auto loc = op.getLoc();
    
    // Create an empty tensor for the output
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, tensorType.getShape(), tensorType.getElementType());
    
    // Create linalg.add operation
    // linalg.add requires: inputs (lhs, rhs) and outputs (destination tensor)
    rewriter.replaceOpWithNewOp<linalg::AddOp>(
        op,
        /*inputs=*/ValueRange{lhs, rhs},
        /*outputs=*/ValueRange{emptyTensor});
    
    return success();
  }
};
struct NovaSubOpLowering : public OpConversionPattern<nova::SubOp> {
  using OpConversionPattern<nova::SubOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::SubOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    // Get operands
    auto operands = adaptor.getOperands();
    
    // Verify we have exactly 2 operands
    if (operands.size() != 2) {
      return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
    }
    
    Value lhs = operands[0];
    Value rhs = operands[1];
    
    // Get the result type
    Type resultType = op.getType();
    
    // Verify result is a tensor type
    auto tensorType = llvm::dyn_cast<RankedTensorType>(resultType);
    if (!tensorType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result type");
    }
    
    auto loc = op.getLoc();
    
    // Create an empty tensor for the output
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, tensorType.getShape(), tensorType.getElementType());
    
    // Create linalg.add operation
    // linalg.add requires: inputs (lhs, rhs) and outputs (destination tensor)
    rewriter.replaceOpWithNewOp<linalg::SubOp>(
        op,
        /*inputs=*/ValueRange{lhs, rhs},
        /*outputs=*/ValueRange{emptyTensor});
    
    return success();
  }
};

struct NovaMulOpLowering : public OpConversionPattern<nova::MulOp> {
  using OpConversionPattern<nova::MulOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::MulOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    // Get operands
    auto operands = adaptor.getOperands();
    
    // Verify we have exactly 2 operands
    if (operands.size() != 2) {
      return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
    }
    
    Value lhs = operands[0];
    Value rhs = operands[1];
    
    // Get the result type
    Type resultType = op.getType();
    
    // Verify result is a tensor type
    auto tensorType = llvm::dyn_cast<RankedTensorType>(resultType);
    if (!tensorType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result type");
    }
    
    auto loc = op.getLoc();
    
    // Create an empty tensor for the output
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, tensorType.getShape(), tensorType.getElementType());
    
    // Create linalg.add operation
    // linalg.add requires: inputs (lhs, rhs) and outputs (destination tensor)
    rewriter.replaceOpWithNewOp<linalg::SubOp>(
        op,
        /*inputs=*/ValueRange{lhs, rhs},
        /*outputs=*/ValueRange{emptyTensor});
    
    return success();
  }
};
struct NovaBroadcastInDimOpLowering : public OpConversionPattern<nova::BroadcastInDimOp> {
  using OpConversionPattern<nova::BroadcastInDimOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::BroadcastInDimOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    
    Value input = adaptor.getOperand();
    
    auto resultType = llvm::dyn_cast<RankedTensorType>(op.getType());
    if (!resultType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result type");
    }
    
    auto inputType = llvm::dyn_cast<RankedTensorType>(input.getType());
    if (!inputType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor input type");
    }
    
    auto loc = op.getLoc();
    auto dimsAttr = op.getBroadcastDimensions();
    
    // Create empty output tensor
    Value emptyTensor = rewriter.create<tensor::EmptyOp>(
        loc, resultType.getShape(), resultType.getElementType());
    
    // Build affine map for input
    SmallVector<AffineExpr> inputExprs;
    for (auto [inputIdx, dimAttr] : llvm::enumerate(dimsAttr.getAsValueRange<IntegerAttr>())) {
      int64_t outputDim = dimAttr.getSExtValue();
      int64_t inputSize = inputType.getDimSize(inputIdx);
      int64_t outputSize = resultType.getDimSize(outputDim);
      
      // If broadcasting dimension (1 -> N), use constant 0
      if (inputSize == 1 && outputSize != 1) {
        inputExprs.push_back(rewriter.getAffineConstantExpr(0));
      } else {
        inputExprs.push_back(rewriter.getAffineDimExpr(outputDim));
      }
    }
    
    // Build affine map for output (identity)
    SmallVector<AffineExpr> outputExprs;
    for (unsigned i = 0; i < resultType.getRank(); ++i) {
      outputExprs.push_back(rewriter.getAffineDimExpr(i));
    }
    
    auto inputMap = AffineMap::get(resultType.getRank(), 0, inputExprs, rewriter.getContext());
    auto outputMap = AffineMap::get(resultType.getRank(), 0, outputExprs, rewriter.getContext());
    
    SmallVector<AffineMap> indexingMaps = {inputMap, outputMap};
    SmallVector<utils::IteratorType> iteratorTypes(resultType.getRank(), 
                                                     utils::IteratorType::parallel);
    
    // Create linalg.generic for broadcast
    auto genericOp = rewriter.create<linalg::GenericOp>(
        loc,
        TypeRange{resultType},
        ValueRange{input},
        ValueRange{emptyTensor},
        indexingMaps,
        iteratorTypes,
        [&](OpBuilder &b, Location loc, ValueRange args) {
          b.create<linalg::YieldOp>(loc, args[0]);
        });
    
    rewriter.replaceOp(op, genericOp.getResults());
    return success();
  }
};
struct NovaMatmulOpLowering : public OpConversionPattern<nova::MatmulOp> {
  using OpConversionPattern<nova::MatmulOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::MatmulOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    
    auto operands = adaptor.getOperands();
    
    if (operands.size() != 2) {
      return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
    }
    
    Value lhs = operands[0];
    Value rhs = operands[1];
    
  
    // Get result type and create empty output tensor
    auto resultType = llvm::dyn_cast<RankedTensorType>(op.getType());
    if (!resultType) {
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result");
    }
    // Create an empty tensor for the output
    Value outputTensor = rewriter.create<tensor::EmptyOp>(
        op.getLoc(),
        resultType.getShape(),
        resultType.getElementType());
    
    // Create linalg.matmul with inputs and output
    rewriter.replaceOpWithNewOp<linalg::MatmulOp>(
        op,
        ValueRange{lhs, rhs},      // inputs
        ValueRange{outputTensor}); // outputs
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass Definition
//===----------------------------------------------------------------------===//

namespace {
struct NovaToLinalgLoweringPass
    : public PassWrapper<NovaToLinalgLoweringPass, OperationPass<func::FuncOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NovaToLinalgLoweringPass)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect,
                    tensor::TensorDialect,
                    func::FuncDialect>();
  }

  StringRef getArgument() const final { return "convert-nova-to-linalg"; }
  
  StringRef getDescription() const final {
    return "Lower Nova dialect operations to Linalg dialect";
  }

  void runOnOperation() override {
    MLIRContext *context = &getContext();
    func::FuncOp funcOp = getOperation();
    
    
    // Define the conversion target
    ConversionTarget target(*context);

    // Mark what is legal after conversion
  target.addLegalDialect<linalg::LinalgDialect>();
  target.addLegalDialect<tensor::TensorDialect>();
  target.addLegalDialect<func::FuncDialect>();
  
  
  // Mark illegal operation dialect
  target.addIllegalOp<nova::MatmulOp>();
  target.addIllegalOp<nova::AddOp>();
  target.addIllegalOp<nova::SubOp>();
  target.addIllegalOp<nova::MulOp>();
  target.addIllegalOp<nova::BroadcastInDimOp>();
  
  // Mark all other ops as legal (dynamic legality)
  target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
  
    // Populate patterns
    RewritePatternSet patterns(context);
    populatenovatolinalgpatterns(patterns); 
    // Apply the conversion
    if (failed(applyPartialConversion(funcOp, target, std::move(patterns)))) {
      signalPassFailure();
      return;
    }

  }
};

} 

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createNovaToLinalgLoweringPass() {
  return std::make_unique<NovaToLinalgLoweringPass>();
}

void registerNovaToLinalgLoweringPass() {
  PassRegistration<NovaToLinalgLoweringPass>();
}
void populatenovatolinalgpatterns(RewritePatternSet &patterns){
    patterns.add<NovaMatmulOpLowering,
    NovaAddOpLowering,
    NovaSubOpLowering,
    NovaMulOpLowering,
    NovaBroadcastInDimOpLowering>
    (patterns.getContext());

}
} // namespace nova
} // namespace mlir