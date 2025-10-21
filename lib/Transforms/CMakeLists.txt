# Add CleanupPass to the list of sources
add_mlir_library(CompilerTransforms
  CleanupPass.cpp
  FuseMatmulInit.cpp

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRPass
  MLIRLLVMDialect
  MLIRTransformUtils
  MLIRNova
  MLIRArithDialect
  MLIRMathDialect 
  MLIRFuncDialect  
  MLIRAffineDialect
  MLIRMemRefDialect     
)