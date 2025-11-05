#ifndef COMPILER_PIPELINE_PIPELINE_H
#define COMPILER_PIPELINE_PIPELINE_H

namespace mlir {
namespace nova {

// Register all Nova pipelines
void registerNovaPipelines();
void createNovaPipelines(OpPassManager &pm);
void registerNovagpuPipelines();
void createNovaGPUPipelines(OpPassManager &pm);} // namespace nova
} // namespace mlir


#endif 