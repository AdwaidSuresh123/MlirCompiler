add_mlir_library(NovaPipelines
  Pipeline.cpp
  Pipelinegpu.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/Compiler

  DEPENDS
  MLIRNovaOpsIncGen

  LINK_LIBS PUBLIC
  MLIRPass
  MLIRTransforms
  MLIRSupport
  MLIRIR
  AffineFullUnroll 
  MLIRNova
  
  MLIRNovaToArithTransforms
  MLIRNovaToMathTransforms
  MLIRNovaToTosaTransforms

  MLIRSCFToControlFlow
  MLIRMemRefToLLVM
  MLIRFuncToLLVM
  MLIRMathToLLVM
  MLIRArithToLLVM
  MLIRControlFlowToLLVM
  MLIRBufferizationToMemRef

)