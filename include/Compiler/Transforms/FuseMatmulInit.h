#ifndef COMPILER_TRANSFORMS_FUSE_MATMUL_INIT_H
#define COMPILER_TRANSFORMS_FUSE_MATMUL_INIT_H

#include "mlir/Pass/Pass.h"

namespace mlir {
namespace nova {

std::unique_ptr<Pass> createFuseMatmulInit();

} // namespace nova
} // namespace mlir

#endif