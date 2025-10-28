//===- NovaToArithLowering.cpp - Lower Nova dialect to Arith dialect ------===//
//
// This file implements a pass to lower Nova dialect operations to Arith dialect
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"

#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/Support/Casting.h"

#include "Compiler/Translation/NovaToMath/NovaToMath.h"

#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/NovaDialect.h"
namespace mlir {
namespace nova {

// Forward declarations (assuming your Nova ops are defined)
// class SinOp;

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//

// // Pattern to convert nova.sin to math.sin
// struct NovaSinOpLowering : public OpConversionPattern<nova::SinOp> {
//   using OpConversionPattern<nova::SinOp>::OpConversionPattern;

//   LogicalResult
//   matchAndRewrite(nova::SinOp op, OpAdaptor adaptor,
//                   ConversionPatternRewriter &rewriter) const override {
//     Location loc = op.getLoc();
//     auto operands = adaptor.getOperands();
//     Value operand = operands[0];
//     Type resultType = op.getType();
//      rewriter.replaceOpWithNewOp<math::SinOp>(op, resultType, operand);
//     return success();
//   }
// };
struct NovaSinOpLowering : public OpConversionPattern<nova::SinOp> {
  using OpConversionPattern<nova::SinOp>::OpConversionPattern;
  
  LogicalResult
  matchAndRewrite(nova::SinOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto operands = adaptor.getOperands();
    Value operand = operands[0];
    Type resultType = op.getType();
    
    ModuleOp module = op->getParentOfType<ModuleOp>();
    //this is to find whether that function declaration is already there or not
    //create declaration if it doesn't exsist
    auto funcOp = module.lookupSymbol<func::FuncOp>("sin");
    if (!funcOp) {
      OpBuilder::InsertionGuard guard(rewriter);
      rewriter.setInsertionPointToStart(module.getBody());

      // find input and output datatypes
      SmallVector<Type, 1> inputTypes = {operand.getType()};
      SmallVector<Type, 1> resultTypes = {resultType};
      
      auto funcType = rewriter.getFunctionType(inputTypes, resultTypes);
      funcOp = rewriter.create<func::FuncOp>(loc, "sin", funcType);
      funcOp.setPrivate();
    }
    
    // Create the function call and capture the result
    auto callOp = rewriter.create<func::CallOp>(
        loc, funcOp, ValueRange{operand});
    
    // Replace the original SinOp with the call result
    rewriter.replaceOp(op, callOp.getResult(0));
    
    return success();
  }
};
//===----------------------------------------------------------------------===//
// Pass Definition
//===----------------------------------------------------------------------===//

namespace {
struct NovaToMathLoweringPass
    : public PassWrapper<NovaToMathLoweringPass, OperationPass<ModuleOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NovaToMathLoweringPass)

void getDependentDialects(DialectRegistry &registry) const override {
  registry.insert<math::MathDialect, LLVM::LLVMDialect, func::FuncDialect>();
}

  StringRef getArgument() const final { return "convert-nova-to-math"; }
  
  StringRef getDescription() const final {
    return "Lower Nova dialect operations to Math dialect";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    
    // Step 1: Define the conversion target
    ConversionTarget target(getContext());
  
    target.addLegalDialect<math::MathDialect, LLVM::LLVMDialect, func::FuncDialect>();
    target.addLegalOp<UnrealizedConversionCastOp>();  // THIS IS CRITICAL
    
    target.addIllegalOp<nova::SinOp>();
    
    // Step 2: Create type converter (if needed)
    TypeConverter typeConverter;
    // Add type conversions if your types differ
    typeConverter.addConversion([](Type type) { return type; });
    
    // Step 3: Create rewrite patterns
    RewritePatternSet patterns(&getContext());
    
    // Populate patterns with our conversion patterns
    patterns.add<NovaSinOpLowering>(
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

// void populateNovaToMathConversionPatterns(RewritePatternSet &patterns,
//                                            TypeConverter &typeConverter) {
//   patterns.add<NovaSinOpLowering>(
//       typeConverter, patterns.getContext());
// }

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createNovaToMathLoweringPass() {
  return std::make_unique<NovaToMathLoweringPass>();
}

// Register the pass
void registerNovaToMathLoweringPass() {
  PassRegistration<NovaToMathLoweringPass>();
}

} // namespace nova
} // namespace mlir