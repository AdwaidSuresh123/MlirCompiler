

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
//functions which will be called inside template
struct NovaOpTosaOp{

template <typename OpTy>
static Value maptop(OpTy op,Type resultType,ValueRange input,OpBuilder* builder){
  return mappingtosa(op,resultType,input,builder);
}

private:
template <typename OpTy>
static Value mappingtosa(OpTy op,Type resultType,ValueRange input,OpBuilder* builder){
  return nullptr;
}
static Value mappingtosa(nova::MaxOp op,Type resultType,ValueRange input,OpBuilder* builder){
  return builder ->create<tosa::MaximumOp>(op.getLoc(),resultType,input[0],input[1]);
}
static Value mappingtosa(nova::MinOp op,Type resultType,ValueRange input,OpBuilder* builder){
  return builder->create<tosa::MinimumOp>(op.getLoc(),resultType,input[0],input[1]);
}
};


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
      APFloat zeroVal = APFloat::getZero(floatType.getFloatSemantics());
      zeroAttr = rewriter.getFloatAttr(floatType, zeroVal);
      
    } else if (auto intType = dyn_cast<IntegerType>(elementType)) {
      zeroAttr = rewriter.getIntegerAttr(intType, 0);
      
    } else {
      return failure();
    }
    DenseElementsAttr zeroTensor = DenseElementsAttr::get(inputType, zeroAttr);
    Value zero = rewriter.create<nova::ConstantOp>(loc, inputType, zeroTensor);
    Value result = rewriter.create<tosa::MaximumOp>(
        loc, inputType, input, zero);
    
    rewriter.replaceOp(op, result);
    return success();
  }
};
//
//creating a template
template <typename NovaTopTy>
class NovaToTosaLoweringTemplate :public OpConversionPattern<NovaTopTy>{
  public:
  using OpConversionPattern<NovaTopTy>::OpConversionPattern;
  using OpAdaptor = typename NovaTopTy::Adaptor; //for getting data type dynamically using adaptor
  LogicalResult matchAndRewrite(NovaTopTy op,OpAdaptor adaptor, ConversionPatternRewriter &rewriter) const override{
    ValueRange operands =adaptor.getOperands();
    //checking operand is empty or not
    if(operands.empty ())
    return rewriter.notifyMatchFailure(op,"expected operands for tosa lowering operations");
  //getting resultType
    auto resultType = dyn_cast<RankedTensorType>(op.getType());
    if (!resultType)
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result");
      Value result = NovaOpTosaOp::maptop(
        op, resultType, operands,&rewriter);
 
    rewriter.replaceOp(op, result);
    return success();
  }
};


//pass definition
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
    ConversionTarget target(getContext());

    target.addLegalDialect<tosa::TosaDialect, func::FuncDialect>();
    target.addLegalOp<nova::ConstantOp>();

    target.addIllegalOp<nova::ReluOp>();
    target.addIllegalOp<nova::MaxOp>();
    target.addIllegalOp<nova::MinOp>();
   

    TypeConverter typeConverter;
    typeConverter.addConversion([](Type type) { return type; });
    RewritePatternSet patterns(&getContext());
    populateNovaToTosaConversionPatterns(patterns);

    if (failed(applyPartialConversion(module, target, std::move(patterns)))) {
      signalPassFailure();
      return;
    }
  }
};

} 

void populateNovaToTosaConversionPatterns(RewritePatternSet &patterns) {
  patterns.add<NovaReluOpLowering,
  NovaToTosaLoweringTemplate<nova::MaxOp>,
  NovaToTosaLoweringTemplate<nova::MinOp>>(
       patterns.getContext());
}

//creating a pointer for this pass
std::unique_ptr<Pass> createNovaToTosaLoweringPass() {
  return std::make_unique<NovaToTosaLoweringPass>();
}

// Register the pass
void registerNovaToTosaLoweringPass() {
  PassRegistration<NovaToTosaLoweringPass>();
}

} // namespace nova
} // namespace mlir