# CMakeLists.txt for Nova to math Lowering Pass

add_mlir_library(MLIRNovaToMathTransforms
  NovaToMath.cpp
  NovaToMath.h

  DEPENDS
  MLIRArithDialect

  LINK_LIBS PUBLIC
  MLIRMathDialect
  MLIRIR
  MLIRPass
  MLIRTransforms
  MLIRTransformUtils
  MLIRNova
)

target_include_directories(MLIRNovaToMathTransforms PRIVATE
  ${PROJECT_SOURCE_DIR}/include/Compiler/Translation/NovaToMath
)