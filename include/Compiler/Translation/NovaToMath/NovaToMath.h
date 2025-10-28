//This file contains header code foer Nova to Math dialect conversion

#ifndef MLIR_CONVERSION_NOVATOMATH_NOVATOMATH_H
#define MLIR_CONVERSION_NOVATOMATH_NOVATOMATH_H

#include "mlir/Pass/Pass.h"
#include <memory>
namespace mlir {
class Pass;
class RewritePatternSet;
class TypeConverter;
namespace nova {

    std::unique_ptr<Pass> createNovaToMathLoweringPass();
    void registerNovaToMathLoweringPass();
    void populateNovaToMathConversionPatterns(RewritePatternSet &patterns,
                                           TypeConverter &typeConverter);
} // namespace nova
} // namespace mlir
#endif

