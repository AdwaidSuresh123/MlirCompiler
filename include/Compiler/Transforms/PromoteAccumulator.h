#ifndef COMPILER_TRANSFORMS_PROMOTE_ACCUMULATOR_H
#define COMPILER_TRANSFORMS_PROMOTE_ACCUMULATOR_H

#include "mlir/Pass/Pass.h"

namespace mlir {
namespace nova {

std::unique_ptr<Pass> createPromoteAccumulator();

} // namespace nova
} // namespace mlir

#endif // COMPILER_TRANSFORMS_PROMOTE_ACCUMULATOR_H