add_llvm_executable(nova-translate nova-translate.cpp)

llvm_update_compile_flags(nova-translate)
target_link_libraries(nova-translate PRIVATE
  MLIRTranslateLib
  MLIRSupport
  MLIRIR
)

# Add all core MLIR dialects
target_link_libraries(nova-translate PRIVATE
  MLIRFuncDialect
  MLIRArithDialect
  MLIRSCFDialect
  MLIRControlFlowDialect
  MLIRTensorDialect
  MLIRMemRefDialect
  MLIRLLVMDialect
  MLIRAffineDialect
  MLIRVectorDialect
)