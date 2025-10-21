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
#include "Compiler/Transforms/FuseMatmulInit.h"

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
  
  // Register only the dialects we need
  registry.insert<mlir::nova::NovaDialect>();
  mlir::registerAllDialects(registry);

  mlir::nova::registerAffinePasses();

  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "Nova dialect optimizer\n", registry));
}
