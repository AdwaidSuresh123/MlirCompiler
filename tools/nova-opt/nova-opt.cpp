#include "mlir/IR/DialectRegistry.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/InitAllPasses.h"

#include "mlir/Transforms/ViewOpGraph.h"
#include "mlir/Transforms/Passes.h"

#include "Compiler/Dialect/nova/NovaDialect.h"
#include "Compiler/Dialect/nova/NovaOps.h"

int main(int argc, char **argv) {
  mlir::registerAllPasses();

  // Register the ViewOpGraph pass specifically
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
    return mlir::createPrintOpGraphPass();
  });

  mlir::DialectRegistry registry;
  
  // Register only the dialects we need
  registry.insert<mlir::nova::NovaDialect>();
  registry.insert<mlir::func::FuncDialect>();
  registry.insert<mlir::arith::ArithDialect>();

  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "Nova dialect optimizer\n", registry));
}
