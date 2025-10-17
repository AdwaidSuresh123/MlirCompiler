# set(CMAKE_INCLUDE_CURRENT_DIR ON)
add_mlir_dialect_library(MLIRNova
  NovaDialect.cpp
  NovaOps.cpp
  NovaCanonicalizations.cpp
  Broadcast.cpp

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/Compiler/Dialect/nova

  DEPENDS
  MLIRNovaOpsIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRInferTypeOpInterface
  MLIRSideEffectInterfaces
  MLIRArithDialect
)

target_include_directories(MLIRNova PRIVATE
  # ${CMAKE_CURRENT_BINARY_DIR}
  ${PROJECT_BINARY_DIR}/include
)
