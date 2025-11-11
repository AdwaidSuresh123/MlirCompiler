//===- NovaToArithLowering.cpp - Lower Nova dialect to Arith dialect ------===//
//
// This file implements a pass to lower Nova dialect operations to Arith dialect
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/Support/Casting.h"


#include "Compiler/Translation/NovaToArith/NovaToArith.h"
#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/NovaDialect.h"
namespace mlir {
namespace nova {

// Forward declarations (assuming your Nova ops are defined)
// class AddOp;
// class SubOp;

//===----------------------------------------------------------------------===//
// Conversion Patterns
//===----------------------------------------------------------------------===//

// // Pattern to convert nova.add to arith.addi/arith.addf
// struct NovaAddOpLowering : public OpConversionPattern<nova::AddOp> {
//   using OpConversionPattern<nova::AddOp>::OpConversionPattern;

//   LogicalResult
//   matchAndRewrite(nova::AddOp op, OpAdaptor adaptor,
//                   ConversionPatternRewriter &rewriter) const override {

    
//     // Get operands - use getOperands() to access all operands
//     auto operands = adaptor.getOperands();
    
//     // Verify we have exactly 2 operands
//     if (operands.size() != 2) {
//       return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
//     }
    
//     Value lhs = operands[0];
//     Value rhs = operands[1];
    
//     // Get the result type
//     Type resultType = op.getType();
    
//     // Handle tensor types - get element type
//     Type elementType = resultType;
//     if (auto tensorType = llvm::dyn_cast<RankedTensorType>(resultType)) {
//       elementType = tensorType.getElementType();
//     } else if (auto tensorType = llvm::dyn_cast<UnrankedTensorType>(resultType)) {
//       elementType = tensorType.getElementType();
//     }
    
//     // Check if the element type is integer or float and create appropriate arith op
//     if (llvm::isa<IntegerType>(elementType)) {
//       // Create arith.addi for integer types
//       rewriter.replaceOpWithNewOp<arith::AddIOp>(op, resultType, lhs, rhs);
//     } else if (llvm::isa<FloatType>(elementType)) {
//       // Create arith.addf for float types
//       rewriter.replaceOpWithNewOp<arith::AddFOp>(op, resultType, lhs, rhs);
//     } else {
//       return rewriter.notifyMatchFailure(op, "unsupported element type");
//     }
    
//     return success();
//   }
// };

// // Pattern to convert nova.sub to arith.subi/arith.subf
// struct NovaSubOpLowering : public OpConversionPattern<nova::SubOp> {
//   using OpConversionPattern<nova::SubOp>::OpConversionPattern;

//   LogicalResult
//   matchAndRewrite(nova::SubOp op, OpAdaptor adaptor,
//                   ConversionPatternRewriter &rewriter) const override {
    

//     // Get operands
//     auto operands = adaptor.getOperands();
    
//     if (operands.size() != 2) {
//       return rewriter.notifyMatchFailure(op, "expected exactly 2 operands");
//     }
    
//     Value lhs = operands[0];
//     Value rhs = operands[1];
//     Type resultType = op.getType();
    
//     // Handle tensor types - get element type
//     Type elementType = resultType;
//     if (auto tensorType = llvm::dyn_cast<RankedTensorType>(resultType)) {
//       elementType = tensorType.getElementType();
//     } else if (auto tensorType = llvm::dyn_cast<UnrankedTensorType>(resultType)) {
//       elementType = tensorType.getElementType();
//     }
    
//     if (llvm::isa<IntegerType>(elementType)) {
//       rewriter.replaceOpWithNewOp<arith::SubIOp>(op, resultType, lhs, rhs);
//     } else if (llvm::isa<FloatType>(elementType)) {
//       rewriter.replaceOpWithNewOp<arith::SubFOp>(op, resultType, lhs, rhs);
//     } else {
//       return rewriter.notifyMatchFailure(op, "unsupported element type");
//     }
    
//     return success();
//   }
// };
//--------------------------------------constant-----------------------------

struct NovaConstantOpLowering 
    : public OpConversionPattern<nova::ConstantOp> {
  using OpConversionPattern<nova::ConstantOp>::OpConversionPattern;

  LogicalResult matchAndRewrite(
      nova::ConstantOp op, OpAdaptor adaptor,
      ConversionPatternRewriter &rewriter) const override {
    
    // Get the value attribute
    Attribute valueAttr = op.getValue();
    
    // // Check if it's a TypedAttr
    auto typedAttr = dyn_cast<TypedAttr>(valueAttr);
    if (!typedAttr) {
      return rewriter.notifyMatchFailure(
          op, "constant value must be a TypedAttr");
    }
    mlir::Type resultType = op.getResult().getType();
    // Create the arith.constant operation
    rewriter.replaceOpWithNewOp<arith::ConstantOp>(op, resultType, typedAttr);
    
    return success();
  }
};


//===----------------------------------------------------------------------===//
// Pass Definition
//===----------------------------------------------------------------------===//

namespace {
struct NovaToArithLoweringPass
    : public PassWrapper<NovaToArithLoweringPass, OperationPass<ModuleOp>> {
  
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NovaToArithLoweringPass)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect>();
    registry.insert<func::FuncDialect>();
  }

  StringRef getArgument() const final { return "convert-nova-to-arith"; }
  
  StringRef getDescription() const final {
    return "Lower Nova dialect operations to Arith dialect";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    
    // Step 1: Define the conversion target
    ConversionTarget target(getContext());
    
    // Mark arith dialect operations as legal
    target.addLegalDialect<arith::ArithDialect>();
    
    // Mark nova dialect operations as illegal (to be converted)
    target.addIllegalOp<nova::AddOp, nova::SubOp,nova::ConstantOp>();
    
    // Optionally, mark other dialects as legal if they exist in your IR
    // target.addLegalDialect<func::FuncDialect>();
    // target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
    
    // Step 2: Create type converter (if needed)
    TypeConverter typeConverter;
    // Add type conversions if your types differ
    typeConverter.addConversion([](Type type) { return type; });
    
    // Step 3: Create rewrite patterns
    RewritePatternSet patterns(&getContext());
    
    // Populate patterns with our conversion patterns
    patterns.add<NovaConstantOpLowering>(
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

// void populateNovaToArithConversionPatterns(RewritePatternSet &patterns,
//                                            TypeConverter &typeConverter) {
//   patterns.add<NovaAddOpLowering, NovaSubOpLowering>(
//       typeConverter, patterns.getContext());
//   patterns.add<NovaConstantOpLowering>(patterns.getContext());
// }

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createNovaToArithLoweringPass() {
  return std::make_unique<NovaToArithLoweringPass>();
}

// Register the pass
void registerNovaToArithLoweringPass() {
  PassRegistration<NovaToArithLoweringPass>();
}

} // namespace nova
} // namespace mlir