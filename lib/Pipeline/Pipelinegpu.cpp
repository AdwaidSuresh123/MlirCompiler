//convert to llvm includes
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVMPass.h"
#include "mlir/Conversion/MathToLLVM/MathToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
//other conversion includes from mlir
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/TosaToLinalg/TosaToLinalg.h"
#include "mlir/Conversion/TosaToTensor/TosaToTensor.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Conversion/TosaToArith/TosaToArith.h"
// GPU conversion includes
#include "mlir/Conversion/GPUToNVVM/GPUToNVVMPass.h"
#include "mlir/Conversion/GPUCommon/GPUCommonPass.h"
#include "mlir/Conversion/VectorToGPU/VectorToGPU.h"
//utils
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
// GPU dialect includes
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/GPU/Transforms/Passes.h"
//buffer includes
#include "mlir/Conversion/BufferizationToMemRef/BufferizationToMemRef.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Bufferization/Pipelines/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/Bufferization/Transforms/Bufferize.h"

//nova dialect includes
#include "Compiler/Dialect/nova/NovaDialect.h"
#include "Compiler/Dialect/nova/NovaOps.h"

//optimization passes includes
#include "Compiler/Transforms/CleanupPass.h"
#include "Compiler/Transforms/AffineFullUnroll.h"
#include "Compiler/Transforms/FastmathFlag.h"
#include "Compiler/Transforms/FuseMatmulInit.h"

//lowering passes
#include "Compiler/Translation/NovaToArith/NovaToArith.h"
#include "Compiler/Translation/NovaToMath/NovaToMath.h"
#include "Compiler/Translation/NovaToTosa/NovaToTosa.h"
#include "Compiler/Translation/NovaToLinalg/NovaToLinalg.h"
// header of this file
#include "Compiler/Pipeline/Pipeline.h"

using namespace mlir;

namespace mlir {
namespace nova {
#define GEN_PASS_REGISTRATION
#include "Compiler/Transforms/Passes.h.inc"

void createNovaGPUPipeline(OpPassManager &pm) {
  pm.addPass(createCanonicalizerPass());
  
  // Lower Nova dialect to standard dialects 
  pm.addPass(createNovaToLinalgLoweringPass());
  pm.addPass(createNovaToArithLoweringPass());
  pm.addPass(createNovaToMathLoweringPass());
  pm.addPass(createCanonicalizerPass());
  pm.addPass(mlir::createReconcileUnrealizedCastsPass());

  //tosa to linalg 
  pm.addNestedPass<func::FuncOp>(mlir::tosa::createTosaToLinalg());  
  //tosa to tensors
  pm.addPass(mlir::createTosaToTensorPass());

  // Convert elementwise operations to Linalg
  pm.addPass(mlir::createConvertElementwiseToLinalgPass());
  
  //  Bufferization (Tensor -> MemRef)
  bufferization::OneShotBufferizePassOptions bufferizeOptions;
  bufferizeOptions.bufferizeFunctionBoundaries = true;
  bufferizeOptions.functionBoundaryTypeConversion =
                bufferization::LayoutMapOption::IdentityLayoutMap;

  pm.addPass(mlir::bufferization::createOneShotBufferizePass(bufferizeOptions));
  
  //  Buffer deallocation pipeline
  bufferization::BufferDeallocationPipelineOptions deallocationOptions;
  bufferization::buildBufferDeallocationPipeline(pm, deallocationOptions);
  
  //Convert remaining bufferization ops to memref
  pm.addPass(mlir::createConvertBufferizationToMemRefPass());
  
  // === GPU-SPECIFIC TRANSFORMATIONS ===
  
  // Convert Linalg to parallel loops first
  pm.addPass(mlir::createConvertLinalgToParallelLoopsPass());
  
  // GPU kernel outlining - extract GPU code into separate kernel functions
  pm.addPass(mlir::createGpuKernelOutliningPass());
  
  // Add GPU async region
  pm.addPass(mlir::createGpuAsyncRegionPass());
  
  // Map parallel loops to GPU
  pm.addNestedPass<func::FuncOp>(mlir::createGpuMapParallelLoopsPass());
  
  pm.addPass(createCanonicalizerPass());
  
  // Lower GPU dialect to NVVM
  pm.addPass(mlir::createConvertGpuOpsToNVVMOps());
  
  // Convert remaining SCF to CF (Control Flow)
  pm.addPass(mlir::createSCFToControlFlowPass());
  pm.addPass(createCanonicalizerPass()); 
  
  //Lower to LLVM dialect
  pm.addPass(createConvertMathToLLVMPass());
  pm.addPass(createArithToLLVMConversionPass());
  pm.addPass(createConvertControlFlowToLLVMPass());
  pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());
  pm.addPass(createConvertFuncToLLVMPass());
  
  // GPU to LLVM conversions for host side
  pm.addPass(mlir::createGpuToLLVMConversionPass());
  
  pm.addPass(mlir::compiler::createCleanupPass());
  // reconcile unrealized casts
  pm.addPass(mlir::createReconcileUnrealizedCastsPass());
  
  // Final canonicalization
  pm.addPass(createCanonicalizerPass());
}

void registerNovagpuPipelines() {
  PassPipelineRegistration<>("nova-gpu-opt-pipeline",
                            "Nova GPU Pipeline",
                            createNovaGPUPipeline);
}

}} // namespace mlir::nova