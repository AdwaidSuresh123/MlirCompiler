add_llvm_executable(nova-opt nova-opt.cpp)

llvm_update_compile_flags(nova-opt)
target_link_libraries(nova-opt PRIVATE
  MLIROptLib
  MLIRParser
  MLIRSupport
  MLIRTransforms
  MLIRAnalysis
  MLIRIR
  MLIRNova
  # Add all MLIR dialects
  MLIRFuncDialect
  MLIRArithDialect
  MLIRSCFDialect
  MLIRControlFlowDialect
  MLIRTensorDialect
  MLIRMemRefDialect
  MLIRLLVMDialect
)
