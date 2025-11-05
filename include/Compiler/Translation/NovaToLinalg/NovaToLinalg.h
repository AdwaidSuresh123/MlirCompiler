#ifndef MLIR_CONVERSION_NOVATOLINALG_H
#define MLIR_CONVERSION_NOVATOLINALG_H

#include "mlir/Pass/Pass.h"
#include <memory>
namespace mlir{
    class Pass;
    class RewritePatternSet;
    class TypeConverter;
    namespace nova{
        std::unique_ptr<Pass> createNovaToLinalgLoweringPass();
        void registerNovaToLinalgLoweringPass();
        void populatenovatolinalgpatterns(RewritePatternSet &patterns);
    }
}
#endif