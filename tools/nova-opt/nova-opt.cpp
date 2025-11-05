#include "mlir/IR/DialectRegistry.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"


#include "mlir/Transforms/ViewOpGraph.h"
#include "mlir/Transforms/Passes.h"

#include "Compiler/Dialect/nova/NovaDialect.h"
#include "Compiler/Dialect/nova/NovaOps.h"
#include "Compiler/Transforms/CleanupPass.h"
#include "Compiler/Transforms/AffineFullUnroll.h"
#include "Compiler/Pipeline/Pipeline.h"

#include "Compiler/Translation/NovaToArith/NovaToArith.h"
#include "Compiler/Translation/NovaToMath/NovaToMath.h"
#include "Compiler/Translation/NovaToTosa/NovaToTosa.h"
#include "Compiler/Translation/NovaToLinalg/NovaToLinalg.h"

#include "Compiler/Transforms/FuseMatmulInit.h"
#include "Compiler/Transforms/FastmathFlag.h"

namespace mlir {
namespace nova {
#define GEN_PASS_REGISTRATION
#include "Compiler/Transforms/Passes.h.inc"
} 
}

int main(int argc, char **argv) {
  mlir::registerAllPasses();

  // Register the ViewOpGraph pass specifically
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
    return mlir::createPrintOpGraphPass();
  });

  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
    return mlir::compiler::createCleanupPass();
  });

  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
    return mlir::nova::createFuseMatmulInit();
  });

  mlir::DialectRegistry registry;
  

  registry.insert<mlir::nova::NovaDialect>();
  mlir::registerAllDialects(registry);
 //registeing pipeline
  mlir::nova::registerNovaPipelines();

//register translation pass-
 mlir::nova::registerNovaToArithLoweringPass();
 mlir::nova::registerNovaToMathLoweringPass();
 mlir::nova::registerNovaToTosaLoweringPass();
 mlir::nova::registerNovaToLinalgLoweringPass();
  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "Nova dialect optimizer\n", registry));
}
