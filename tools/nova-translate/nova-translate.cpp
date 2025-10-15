#include "mlir/InitAllDialects.h"
#include "mlir/Tools/mlir-translate/mlir-translate.h"
#include "mlir/Tools/mlir-translate/Translation.h"

int main(int argc, char **argv) {
  mlir::DialectRegistry registry;
  mlir::registerAllDialects(registry);
  
  return mlir::mlirTranslateMain(argc, argv, registry);
}