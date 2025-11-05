

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/Support/Casting.h"


#include "Compiler/Translation/NovaToTosa/NovaToTosa.h"
#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/NovaDialect.h"
namespace mlir {
namespace nova {

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//

// Pattern to convert nova.relu to tosa.relu
struct NovaReluOpLowering : public OpConversionPattern<ReluOp> {
  using OpConversionPattern<ReluOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(ReluOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Value input = adaptor.getInput();
    auto inputType = cast<RankedTensorType>(input.getType());
    Type elementType = inputType.getElementType();
    
    // Create zero constant tensor with the same shape as input
    Attribute zeroAttr;
    
    if (auto floatType = dyn_cast<FloatType>(elementType)) {
      // For floating point: 0.0
      APFloat zeroVal = APFloat::getZero(floatType.getFloatSemantics());
      zeroAttr = rewriter.getFloatAttr(floatType, zeroVal);
      
    } else if (auto intType = dyn_cast<IntegerType>(elementType)) {
      // For integer types: 0
      zeroAttr = rewriter.getIntegerAttr(intType, 0);
      
    } else {
      return failure();
    }
    
    // Create a splat constant tensor filled with zeros
    DenseElementsAttr zeroTensor = DenseElementsAttr::get(inputType, zeroAttr);
    Value zero = rewriter.create<nova::ConstantOp>(loc, inputType, zeroTensor);
    
    // Create tosa.maximum: max(input, 0)
    Value result = rewriter.create<tosa::MaximumOp>(
        loc, inputType, input, zero);
    
    rewriter.replaceOp(op, result);
    return success();
  }
};


//===----------------------------------------------------------------------===//
// Pass Definition
//===----------------------------------------------------------------------===//

namespace {
struct NovaToTosaLoweringPass
    : public PassWrapper<NovaToTosaLoweringPass, OperationPass<ModuleOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NovaToTosaLoweringPass)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<tosa::TosaDialect>();
    registry.insert<func::FuncDialect>();
    registry.insert<nova::NovaDialect>();
  }

  StringRef getArgument() const final { return "convert-nova-to-tosa"; }
  
  StringRef getDescription() const final {
    return "Lower Nova dialect operations to Tosa dialect";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    
    // Step 1: Define the conversion target
    ConversionTarget target(getContext());
    
    // Mark arith dialect operations as legal
    target.addLegalDialect<tosa::TosaDialect, func::FuncDialect>();
    target.addLegalOp<nova::ConstantOp>();
    // Mark nova dialect operations as illegal (to be converted)
    target.addIllegalOp<nova::ReluOp>();

    TypeConverter typeConverter;
    // Add type conversions if your types differ
    typeConverter.addConversion([](Type type) { return type; });
    
    // Step 3: Create rewrite patterns
    RewritePatternSet patterns(&getContext());
    
    // Populate patterns with our conversion patterns
    patterns.add<NovaReluOpLowering>(
        typeConverter, &getContext());
    // Step 4: Apply the conversion
    if (failed(applyPartialConversion(module, target, std::move(patterns)))) {
      signalPassFailure();
      return;
    }
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pattern Population
//===----------------------------------------------------------------------===//

// void populateNovaToTosaConversionPatterns(RewritePatternSet &patterns,
//                                            TypeConverter &typeConverter) {
//   patterns.add<NovaReluOpLowering>(
//       typeConverter, patterns.getContext());
// }

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createNovaToTosaLoweringPass() {
  return std::make_unique<NovaToTosaLoweringPass>();
}

// Register the pass
void registerNovaToTosaLoweringPass() {
  PassRegistration<NovaToTosaLoweringPass>();
}

} // namespace nova
} // namespace mlir