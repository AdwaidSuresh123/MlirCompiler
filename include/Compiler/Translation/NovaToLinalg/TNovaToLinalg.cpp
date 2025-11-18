#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Math/IR/Math.h"

#include "Compiler/Translation/NovaToLinalg/NovaToLinalg.h"
#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/NovaDialect.h"

namespace mlir {
namespace nova {

// Helper Utilities
inline bool isScalar(Value v) {
  auto type = dyn_cast<RankedTensorType>(v.getType());
  return !type || type.getRank() == 0;
}

inline SmallVector<utils::IteratorType> getNParallelLoopsAttrs(unsigned n) {
  return SmallVector<utils::IteratorType>(n, utils::IteratorType::parallel);
}

// Scalar Operation Mapper

struct NovaOpToStdScalarOp {
  template <typename OpTy>
  //kind of main function
  static Value mapOp(OpTy op, Type resultType, ArrayRef<Value> args,
                     OpBuilder* builder) {
    return mapOpImpl(op, resultType, args, builder);
  }          

 //default function to return null ptr if the operation didn't match
private:
  template <typename OpTy>
  static Value mapOpImpl(OpTy op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return nullptr;
  }
//Add operation
  static Value mapOpImpl(nova::AddOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    if (isa<FloatType>(resultType))
      return builder->create<arith::AddFOp>(op.getLoc(), args[0], args[1]);
    if (isa<IntegerType>(resultType))
      return builder->create<arith::AddIOp>(op.getLoc(), args[0], args[1]);
    return nullptr;
  }
//sub operation
  static Value mapOpImpl(nova::SubOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    if (isa<FloatType>(resultType))
      return builder->create<arith::SubFOp>(op.getLoc(), args[0], args[1]);
    if (isa<IntegerType>(resultType))
      return builder->create<arith::SubIOp>(op.getLoc(), args[0], args[1]);
    return nullptr;
  }
//mul operation 
  static Value mapOpImpl(nova::MulOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    if (isa<FloatType>(resultType))
      return builder->create<arith::MulFOp>(op.getLoc(), args[0], args[1]);
    if (isa<IntegerType>(resultType))
      return builder->create<arith::MulIOp>(op.getLoc(), args[0], args[1]);
    return nullptr;
  }
  //pow operation
  static Value mapOpImpl(nova::PowOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    if (isa<FloatType>(resultType))
      return builder->create<math::PowFOp>(op.getLoc(), args[0], args[1]);
    if(isa<IntegerType>(resultType))
      return builder->create<math::IPowIOp>(op.getLoc(), args[0], args[1]);
    return nullptr;
  }

  //abs operation
  static Value mapOpImpl(nova::AbsOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<FloatType>(resultType))
    return builder->create<math::AbsFOp>(op.getLoc(),args[0]);
    if(isa<IntegerType>(resultType))
    return builder->create<math::AbsIOp>(op.getLoc(),args[0]);
    return nullptr;
  }
  //sqrt operation
  static Value mapOpImpl(nova::SqrtOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    return builder ->create<math::SqrtOp>(op.getLoc(),args[0]);
  }
  //div operation
  static Value mapOpImpl(nova::DivOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){

    if(isa<FloatType>(resultType))
    return builder->create<arith::DivFOp>(op.getLoc(),args[0],args[1]);
    if(isa<IntegerType>(resultType))
    return builder->create<arith::DivUIOp>(op.getLoc(),args[0],args[1]);
    return nullptr;
  }
  //mod operation
  //only float type
  static Value mapOpImpl(nova::ModOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<FloatType>(resultType))
    return builder->create<arith::RemFOp>(op.getLoc(),args[0],args[1]);
    return nullptr;
  }
  //and operation
  //only integer type
  static Value mapOpImpl(nova::AndOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<IntegerType>(resultType))
    return builder ->create<arith::AndIOp>(op.getLoc(),args[0],args[1]);
    return nullptr;
  }
  // //or operation
    static Value mapOpImpl(nova::OrOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<IntegerType>(resultType))
    return builder ->create<arith::OrIOp>(op.getLoc(),args[0],args[1]);
    return nullptr;
  }
  // //xor operation
    static Value mapOpImpl(nova::XorOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<IntegerType>(resultType))
    return builder ->create<arith::XOrIOp>(op.getLoc(),args[0],args[1]);
    return nullptr;
  }
  //Square operation
    static Value mapOpImpl(nova::SquareOp op,Type resultType,ArrayRef<Value> args,OpBuilder* builder){
    if(isa<FloatType>(resultType))
    return builder ->create<arith::MulFOp>(op.getLoc(),args[0],args[0]);
    if(isa<IntegerType>(resultType))
    return builder ->create<arith::MulIOp>(op.getLoc(),args[0],args[0]);
    return nullptr;
}
//--------------------------------------------------------
//EXPONENTS
//-----------------------------------------------------------
//exp operaton
  static Value mapOpImpl(nova::ExpOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
   if(isa<FloatType>(args[0].getType()))
    return builder->create<math::ExpOp>(op.getLoc(), args[0]);
   if(isa<IntegerType>(args[0].getType()))
    return builder->create<math::ExpOp>(op.getLoc(), 
     builder->create<arith::SIToFPOp>(op.getLoc(),builder->getF32Type(),args[0]));
   return nullptr;
    }
//exp2 operaton
  static Value mapOpImpl(nova::Exp2Op op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
  if(isa<FloatType>(args[0].getType()))
    return builder->create<math::Exp2Op>(op.getLoc(), args[0]);
  if(isa<IntegerType>(args[0].getType()))
   return builder->create<math::Exp2Op>(op.getLoc(), 
   builder->create<arith::SIToFPOp>(op.getLoc(),builder->getF32Type(),args[0]));
    return nullptr;
  }
//log operaton
  static Value mapOpImpl(nova::LogOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::LogOp>(op.getLoc(), args[0]);
  }
//log2 operaton
  static Value mapOpImpl(nova::Log2Op op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::Log2Op>(op.getLoc(), args[0]);
  }
  //log10 operaton
  static Value mapOpImpl(nova::Log10Op op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::Log10Op>(op.getLoc(), args[0]);
  }
//----------------------------------------------------
//TRIGNOMENTARY OPERATIONS
//--------------------------------------------------------------------
//sin operaton
  static Value mapOpImpl(nova::SinOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::SinOp>(op.getLoc(), args[0]);
  }
//cos operation
  static Value mapOpImpl(nova::CosOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::CosOp>(op.getLoc(), args[0]); 
  }
  
//tan operation
  static Value mapOpImpl(nova::TanOp op, Type resultType, ArrayRef<Value> args,
                         OpBuilder* builder) {
    return builder->create<math::TanOp>(op.getLoc(), args[0]);  }
};



//generic pattern definition

template <typename NovaOpTy>
class NovaToLinalgElementwiseConverter : public OpConversionPattern<NovaOpTy> {
public:
  using OpConversionPattern<NovaOpTy>::OpConversionPattern;//creates a constructor
  using OpAdaptor = typename NovaOpTy::Adaptor; //for getting data type dynamically using adaptor

  LogicalResult
  matchAndRewrite(NovaOpTy op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto operands = adaptor.getOperands();
    if (operands.empty())
      return rewriter.notifyMatchFailure(op, "expected operands for linalg lowering operations");
    //checking if operand is ranked tensortype
    auto resultType = dyn_cast<RankedTensorType>(op.getType());
    if (!resultType)
      return rewriter.notifyMatchFailure(op, "expected ranked tensor result");
    //each element type
auto resultDataType=resultType.getElementType();
//casting
    std::string opName = op.getOperationName().str();
    const std::set<std::string> allowedOps ={"nova.exp","nova.exp2"};
     if (allowedOps.count(opName)) {
      //change the re
     resultDataType = rewriter.getF32Type(); 
     }
                                                   
    // Create output tensor
    Value out = rewriter.create<tensor::EmptyOp>(
        op.getLoc(), resultType.getShape(), resultDataType);

    // Prepare affine maps
    int64_t rank = resultType.getRank();
    AffineMap scalarMap = AffineMap::get(rank, 0, rewriter.getContext());
    AffineMap idMap = rewriter.getMultiDimIdentityMap(rank);
    SmallVector<AffineMap> maps;
    for (Value v : operands)
      maps.push_back(isScalar(v) ? scalarMap : idMap);
    maps.push_back(idMap);

    // Create Linalg generic
    auto linalgOp = rewriter.create<linalg::GenericOp>(
        op.getLoc(), out.getType(), operands, out, maps,
        getNParallelLoopsAttrs(rank),
        [&](OpBuilder &b, Location loc, ValueRange args) {
          Type elemType = getElementTypeOrSelf(out);
          SmallVector<Value> argVec(args.begin(), args.end());
//call our custom lowering functions
          Value inner = NovaOpToStdScalarOp::mapOp(op, elemType, argVec, &b);
          if (!inner)
            return; //op failed to map 
          b.create<linalg::YieldOp>(loc, inner);
        });

    rewriter.replaceOp(op, linalgOp->getResults());
    return success();
  }
};


//---------------=-------------------=------------------=---------------------
// Pass Definition

namespace {
struct NovaToLinalgLoweringPassTemplate
    : public PassWrapper<NovaToLinalgLoweringPassTemplate, OperationPass<func::FuncOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NovaToLinalgLoweringPassTemplate)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<linalg::LinalgDialect,
                    tensor::TensorDialect,
                    arith::ArithDialect,
                    func::FuncDialect>();
  }

  StringRef getArgument() const final { return "convert-nova-to-linalg"; }
  
  StringRef getDescription() const final {
    return "Lower Nova dialect operations to Linalg dialect";
  }

  void runOnOperation() override {
    MLIRContext *context = &getContext();
    func::FuncOp funcOp = getOperation();
    ConversionTarget target(*context);

    target.addLegalDialect<linalg::LinalgDialect>();
    target.addLegalDialect<tensor::TensorDialect>();
    target.addLegalDialect<arith::ArithDialect>();
    target.addLegalDialect<func::FuncDialect>();
    target.addLegalDialect<math::MathDialect>();

    target.addIllegalOp<nova::AbsOp>();
    target.addIllegalOp<nova::AddOp>();
    target.addIllegalOp<nova::SubOp>();
    target.addIllegalOp<nova::MulOp>();
    target.addIllegalOp<nova::MatmulOp>();
    target.addIllegalOp<nova::PowOp>();
    target.addIllegalOp<nova::SinOp>();
    target.addIllegalOp<nova::BroadcastInDimOp>();
    target.addIllegalOp<nova::DivOp>();
    target.addIllegalOp<nova::ModOp>();
    target.addIllegalOp<nova::AndOp>();
    target.addIllegalOp<nova::OrOp>();
    target.addIllegalOp<nova::XorOp>();
    target.addIllegalOp<nova::SquareOp>();
    target.addIllegalOp<nova::SqrtOp>();
    target.addIllegalOp<nova::LogOp>();
    target.addIllegalOp<nova::ExpOp>();
    target.addIllegalOp<nova::Exp2Op>();
    target.addIllegalOp<nova::Log2Op>();
    target.addIllegalOp<nova::Log10Op>();    
    target.addIllegalOp<nova::CosOp>();
    target.addIllegalOp<nova::TanOp>();

    target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
    RewritePatternSet patterns(context);
    populateNovaToLinalgPatterns(patterns); 
    populateNovaToLinalgPatternsTemplate(patterns);
    if (failed(applyPartialConversion(funcOp, target, std::move(patterns)))) {
      signalPassFailure();
      return;
    }
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass Registration & Pattern Population
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createNovaToLinalgLoweringPass() {
  return std::make_unique<NovaToLinalgLoweringPassTemplate>();
}

void regsiterNovaToLinalgLoweringTemplatePass() {
  PassRegistration<NovaToLinalgLoweringPassTemplate>();
}

void populateNovaToLinalgPatternsTemplate(RewritePatternSet &patterns) {
  // Use generic converters for pointwise ops
  patterns.add<
      NovaToLinalgElementwiseConverter<nova::AddOp>,
      NovaToLinalgElementwiseConverter<nova::SubOp>,
      NovaToLinalgElementwiseConverter<nova::MulOp>,
      NovaToLinalgElementwiseConverter<nova::PowOp>,
      NovaToLinalgElementwiseConverter<nova::SinOp>,
      NovaToLinalgElementwiseConverter<nova::AbsOp>,
      NovaToLinalgElementwiseConverter<nova::DivOp>,
      NovaToLinalgElementwiseConverter<nova::ModOp>,
      NovaToLinalgElementwiseConverter<nova::AndOp>, 
      NovaToLinalgElementwiseConverter<nova::OrOp>, 
      NovaToLinalgElementwiseConverter<nova::XorOp>,
      NovaToLinalgElementwiseConverter<nova::SquareOp>,
      NovaToLinalgElementwiseConverter<nova::SqrtOp>,
      NovaToLinalgElementwiseConverter<nova::LogOp>,
      NovaToLinalgElementwiseConverter<nova::ExpOp>,
      NovaToLinalgElementwiseConverter<nova::Exp2Op>,
      NovaToLinalgElementwiseConverter<nova::Log2Op>,
      NovaToLinalgElementwiseConverter<nova::Log10Op>,
      NovaToLinalgElementwiseConverter<nova::CosOp>,
      NovaToLinalgElementwiseConverter<nova::TanOp>

  >(patterns.getContext());
}

} // namespace nova
} // namespace mlir
