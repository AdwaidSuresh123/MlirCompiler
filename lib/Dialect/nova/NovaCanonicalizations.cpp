//===----------------------------------------------------------------------===//
// NovaCanonicalizations.cpp - Canonicalization patterns for Nova dialect
//===----------------------------------------------------------------------===//

#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Dialect/nova/Broadcast.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace mlir::nova;

namespace {

//===----------------------------------------------------------------------===//
// Broadcast Insertion Pattern (Generic for all binary ops)
//===----------------------------------------------------------------------===//

template<typename OpType>
struct InsertBroadcastPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto lhsType = dyn_cast<RankedTensorType>(op.getLhs().getType());
    auto rhsType = dyn_cast<RankedTensorType>(op.getRhs().getType());
    auto resultType = dyn_cast<RankedTensorType>(op.getResult().getType());

    if (!lhsType || !rhsType || !resultType) {
      return failure();
    }

    if (lhsType.getShape() == resultType.getShape() &&
        rhsType.getShape() == resultType.getShape()) {
      return failure();
    }

    Value newLhs = op.getLhs();
    Value newRhs = op.getRhs();
    bool changed = false;

    if (lhsType.getShape() != resultType.getShape()) {
      if (lhsType.getRank() > resultType.getRank()) {
        return failure();
      }
      if (!isBroadcastCompatible(lhsType.getShape(), resultType.getShape())) {
        return failure();
      }
      
      auto broadcastDims = computeBroadcastDimensions(
          lhsType.getRank(), resultType.getRank());
      
      auto broadcastDimsAttr = rewriter.getI64ArrayAttr(broadcastDims);
      
      newLhs = rewriter.create<BroadcastInDimOp>(
          op.getLoc(), resultType, newLhs, broadcastDimsAttr).getResult();
      changed = true;
    }

    if (rhsType.getShape() != resultType.getShape()) {
      if (rhsType.getRank() > resultType.getRank()) {
        return failure();
      }
      if (!isBroadcastCompatible(rhsType.getShape(), resultType.getShape())) {
        return failure();
      }
      
      auto broadcastDims = computeBroadcastDimensions(
          rhsType.getRank(), resultType.getRank());
      
      auto broadcastDimsAttr = rewriter.getI64ArrayAttr(broadcastDims);
      
      newRhs = rewriter.create<BroadcastInDimOp>(
          op.getLoc(), resultType, newRhs, broadcastDimsAttr).getResult();
      changed = true;
    }

    if (!changed) {
      return failure();
    }

    rewriter.replaceOpWithNewOp<OpType>(op, op.getResult().getType(), newLhs, newRhs);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AddOp Canonicalization Patterns
//===----------------------------------------------------------------------===//

/// Eliminate A + 0 -> A
struct EliminateAddZero : public OpRewritePattern<AddOp> {
  using OpRewritePattern<AddOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AddOp op,
                                PatternRewriter &rewriter) const override {
    // Check if RHS is a zero constant
    if (auto rhsDefOp = op.getRhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(rhsDefOp.getValue())) {
        if (denseAttr.isSplat() && 
            denseAttr.getSplatValue<APFloat>().isZero()) {
          rewriter.replaceOp(op, op.getLhs());
          return success();
        }
      }
    }

    // Check if LHS is zero
    if (auto lhsDefOp = op.getLhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(lhsDefOp.getValue())) {
        if (denseAttr.isSplat() && 
            denseAttr.getSplatValue<APFloat>().isZero()) {
          rewriter.replaceOp(op, op.getRhs());
          return success();
        }
      }
    }

    return failure();
  }
};

/// Combine consecutive additions: (A + c1) + c2 -> A + (c1 + c2)
struct CombineAddConstants : public OpRewritePattern<AddOp> {
  using OpRewritePattern<AddOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AddOp op,
                                PatternRewriter &rewriter) const override {
    auto lhsAdd = op.getLhs().getDefiningOp<AddOp>();
    if (!lhsAdd)
      return failure();

    auto rhsConst = op.getRhs().getDefiningOp<arith::ConstantOp>();
    if (!rhsConst)
      return failure();

    auto lhsRhsConst = lhsAdd.getRhs().getDefiningOp<arith::ConstantOp>();
    if (!lhsRhsConst)
      return failure();

    auto rhsAttr = dyn_cast<DenseElementsAttr>(rhsConst.getValue());
    auto lhsRhsAttr = dyn_cast<DenseElementsAttr>(lhsRhsConst.getValue());
    
    if (!rhsAttr || !lhsRhsAttr || !rhsAttr.isSplat() || !lhsRhsAttr.isSplat())
      return failure();

    APFloat val1 = rhsAttr.getSplatValue<APFloat>();
    APFloat val2 = lhsRhsAttr.getSplatValue<APFloat>();
    APFloat combined = val1;
    combined.add(val2, APFloat::rmNearestTiesToEven);

    auto newConstAttr = DenseElementsAttr::get(
        cast<ShapedType>(rhsConst.getType()), combined);
    auto newConst = rewriter.create<arith::ConstantOp>(
        op.getLoc(), newConstAttr);

    rewriter.replaceOpWithNewOp<AddOp>(
        op, op.getType(), lhsAdd.getLhs(), newConst);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// SubOp Canonicalization Patterns
//===----------------------------------------------------------------------===//

/// Eliminate A - 0 -> A
struct EliminateSubZero : public OpRewritePattern<SubOp> {
  using OpRewritePattern<SubOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(SubOp op,
                                PatternRewriter &rewriter) const override {
    if (auto rhsDefOp = op.getRhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(rhsDefOp.getValue())) {
        if (denseAttr.isSplat() && 
            denseAttr.getSplatValue<APFloat>().isZero()) {
          rewriter.replaceOp(op, op.getLhs());
          return success();
        }
      }
    }
    return failure();
  }
};

/// Eliminate A - A -> 0
struct EliminateSubSelf : public OpRewritePattern<SubOp> {
  using OpRewritePattern<SubOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(SubOp op,
                                PatternRewriter &rewriter) const override {
    if (op.getLhs() != op.getRhs())
      return failure();

    auto resultType = cast<ShapedType>(op.getResult().getType());
    auto zeroAttr = DenseElementsAttr::get(
        resultType,
        rewriter.getFloatAttr(resultType.getElementType(), 0.0));
    
    rewriter.replaceOpWithNewOp<arith::ConstantOp>(op, zeroAttr);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// MulOp Canonicalization Patterns
//===----------------------------------------------------------------------===//

/// Eliminate A * 1 -> A
struct EliminateMulOne : public OpRewritePattern<MulOp> {
  using OpRewritePattern<MulOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(MulOp op,
                                PatternRewriter &rewriter) const override {
    if (auto rhsDefOp = op.getRhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(rhsDefOp.getValue())) {
        if (denseAttr.isSplat()) {
          APFloat val = denseAttr.getSplatValue<APFloat>();
          if (val.isExactlyValue(1.0)) {
            rewriter.replaceOp(op, op.getLhs());
            return success();
          }
        }
      }
    }

    if (auto lhsDefOp = op.getLhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(lhsDefOp.getValue())) {
        if (denseAttr.isSplat()) {
          APFloat val = denseAttr.getSplatValue<APFloat>();
          if (val.isExactlyValue(1.0)) {
            rewriter.replaceOp(op, op.getRhs());
            return success();
          }
        }
      }
    }

    return failure();
  }
};

/// Eliminate A * 0 -> 0
struct EliminateMulZero : public OpRewritePattern<MulOp> {
  using OpRewritePattern<MulOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(MulOp op,
                                PatternRewriter &rewriter) const override {
    Value zeroOperand = nullptr;
    
    if (auto rhsDefOp = op.getRhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(rhsDefOp.getValue())) {
        if (denseAttr.isSplat() && 
            denseAttr.getSplatValue<APFloat>().isZero()) {
          zeroOperand = op.getRhs();
        }
      }
    }

    if (!zeroOperand) {
      if (auto lhsDefOp = op.getLhs().getDefiningOp<arith::ConstantOp>()) {
        if (auto denseAttr = dyn_cast<DenseElementsAttr>(lhsDefOp.getValue())) {
          if (denseAttr.isSplat() && 
              denseAttr.getSplatValue<APFloat>().isZero()) {
            zeroOperand = op.getLhs();
          }
        }
      }
    }

    if (zeroOperand) {
      rewriter.replaceOp(op, zeroOperand);
      return success();
    }

    return failure();
  }
};

/// Combine consecutive multiplications: (A * c1) * c2 -> A * (c1 * c2)
struct CombineMulConstants : public OpRewritePattern<MulOp> {
  using OpRewritePattern<MulOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(MulOp op,
                                PatternRewriter &rewriter) const override {
    auto lhsMul = op.getLhs().getDefiningOp<MulOp>();
    if (!lhsMul)
      return failure();

    auto rhsConst = op.getRhs().getDefiningOp<arith::ConstantOp>();
    if (!rhsConst)
      return failure();

    auto lhsRhsConst = lhsMul.getRhs().getDefiningOp<arith::ConstantOp>();
    if (!lhsRhsConst)
      return failure();

    auto rhsAttr = dyn_cast<DenseElementsAttr>(rhsConst.getValue());
    auto lhsRhsAttr = dyn_cast<DenseElementsAttr>(lhsRhsConst.getValue());
    
    if (!rhsAttr || !lhsRhsAttr || !rhsAttr.isSplat() || !lhsRhsAttr.isSplat())
      return failure();

    APFloat val1 = rhsAttr.getSplatValue<APFloat>();
    APFloat val2 = lhsRhsAttr.getSplatValue<APFloat>();
    APFloat combined = val1;
    combined.multiply(val2, APFloat::rmNearestTiesToEven);

    auto newConstAttr = DenseElementsAttr::get(
        cast<ShapedType>(rhsConst.getType()), combined);
    auto newConst = rewriter.create<arith::ConstantOp>(
        op.getLoc(), newConstAttr);

    rewriter.replaceOpWithNewOp<MulOp>(
        op, op.getType(), lhsMul.getLhs(), newConst);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// DivOp Canonicalization Patterns
//===----------------------------------------------------------------------===//

/// Eliminate A / 1 -> A
struct EliminateDivOne : public OpRewritePattern<DivOp> {
  using OpRewritePattern<DivOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DivOp op,
                                PatternRewriter &rewriter) const override {
    if (auto rhsDefOp = op.getRhs().getDefiningOp<arith::ConstantOp>()) {
      if (auto denseAttr = dyn_cast<DenseElementsAttr>(rhsDefOp.getValue())) {
        if (denseAttr.isSplat()) {
          APFloat val = denseAttr.getSplatValue<APFloat>();
          if (val.isExactlyValue(1.0)) {
            rewriter.replaceOp(op, op.getLhs());
            return success();
          }
        }
      }
    }
    return failure();
  }
};

//===----------------------------------------------------------------------===//
// MaxOp/MinOp Canonicalization Patterns
//===----------------------------------------------------------------------===//

/// Simplify max(A, A) -> A
struct SimplifyMaxSelf : public OpRewritePattern<MaxOp> {
  using OpRewritePattern<MaxOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(MaxOp op,
                                PatternRewriter &rewriter) const override {
    if (op.getLhs() != op.getRhs())
      return failure();

    rewriter.replaceOp(op, op.getLhs());
    return success();
  }
};

/// Simplify min(A, A) -> A
struct SimplifyMinSelf : public OpRewritePattern<MinOp> {
  using OpRewritePattern<MinOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(MinOp op,
                                PatternRewriter &rewriter) const override {
    if (op.getLhs() != op.getRhs())
      return failure();

    rewriter.replaceOp(op, op.getLhs());
    return success();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Populate Canonicalization Patterns (called from each Op)
//===----------------------------------------------------------------------===//

void AddOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<AddOp>>(context);
  results.add<EliminateAddZero>(context);
  results.add<CombineAddConstants>(context);
}

void SubOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<SubOp>>(context);
  results.add<EliminateSubZero>(context);
  results.add<EliminateSubSelf>(context);
}

void MulOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MulOp>>(context);
  results.add<EliminateMulOne>(context);
  results.add<EliminateMulZero>(context);
  results.add<CombineMulConstants>(context);
}

void DivOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<DivOp>>(context);
  results.add<EliminateDivOne>(context);
}

void RemOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<RemOp>>(context);
}

void PowOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<PowOp>>(context);
}

void MaxOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MaxOp>>(context);
  results.add<SimplifyMaxSelf>(context);
}

void MinOp::getCanonicalizationPatterns(RewritePatternSet &results, 
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<MinOp>>(context);
  results.add<SimplifyMinSelf>(context);
}

void AndOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<AndOp>>(context);
}

void OrOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                       MLIRContext *context) {
  results.add<InsertBroadcastPattern<OrOp>>(context);
}

void XorOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                        MLIRContext *context) {
  results.add<InsertBroadcastPattern<XorOp>>(context);
}