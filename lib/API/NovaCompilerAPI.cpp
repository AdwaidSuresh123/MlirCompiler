#include "Compiler/API/NovaCompilerAPI.h"
#include "Compiler/Pipeline/Pipeline.h"
#include "Compiler/Dialect/nova/NovaDialect.h"

#include "mlir/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Linalg/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.h"

#include "mlir/Parser/Parser.h"
#include "mlir/IR/Verifier.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Target/LLVMIR/Export.h"
#include "mlir/Target/LLVMIR/Dialect/All.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/IR/Module.h"

#include <cstdlib>
#include <array>
#include <memory>
#include <sstream>
#include <fstream>

using namespace mlir;
using namespace mlir::nova;

//----------------------------------------------------------------------------//
// NovaCompilerAPI Implementation
//----------------------------------------------------------------------------//

NovaCompilerAPI::NovaCompilerAPI() {
  context = std::make_unique<MLIRContext>();
  
  // Create and populate dialect registry first
  DialectRegistry registry;
  
  // Register Nova dialect
  registry.insert<mlir::nova::NovaDialect>();
  
  mlir::tensor::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::linalg::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::bufferization::func_ext::registerBufferizableOpInterfaceExternalModels(registry);


  // Register LLVM IR translation
  registerLLVMDialectTranslation(registry);
  registerAllToLLVMIRTranslations(registry);
  
  context->appendDialectRegistry(registry);
  
  context->loadAllAvailableDialects();
}

NovaCompilerAPI::~NovaCompilerAPI() = default;

CompilationResult NovaCompilerAPI::compileFile(const std::string &inputFile,
                                               const std::string &outputFile,
                                               const CompilerOptions &options) {
  CompilationResult result;
  
  // Parse the input file
  std::string errorMessage;
  auto fileOrErr = llvm::MemoryBuffer::getFile(inputFile);
  if (std::error_code ec = fileOrErr.getError()) {
    result.success = false;
    result.errorMessage = "Failed to open file: " + ec.message();
    return result;
  }
  
  llvm::SourceMgr sourceMgr;
  sourceMgr.AddNewSourceBuffer(std::move(*fileOrErr), llvm::SMLoc());
  
  OwningOpRef<ModuleOp> module = parseSourceFile<ModuleOp>(sourceMgr, context.get());
  if (!module) {
    result.success = false;
    result.errorMessage = "Failed to parse MLIR file";
    return result;
  }
  
  return compileModule(*module, outputFile, options);
}

CompilationResult NovaCompilerAPI::compileString(const std::string &mlirSource,
                                                 const std::string &outputFile,
                                                 const CompilerOptions &options) {
  CompilationResult result;
  
  // Parse the MLIR string
  OwningOpRef<ModuleOp> module = parseSourceString<ModuleOp>(mlirSource, context.get());
  if (!module) {
    result.success = false;
    result.errorMessage = "Failed to parse MLIR string";
    return result;
  }
  
  return compileModule(*module, outputFile, options);
}

CompilationResult NovaCompilerAPI::compileModule(ModuleOp module,
                                                 const std::string &outputFile,
                                                 const CompilerOptions &options) {
  CompilationResult result;
  
  // Verify the module
  if (failed(verify(module))) {
    result.success = false;
    result.errorMessage = "Module verification failed";
    return result;
  }
  
  // Run the pipeline
  if (failed(runPipeline(module, options))) {
    result.success = false;
    result.errorMessage = "Pipeline execution failed";
    return result;
  }
  
  // Generate output
  std::string output;
  if (options.outputLLVMIR) {
    output = translateToLLVMIR(module);
    if (output.empty()) {
      result.success = false;
      result.errorMessage = "LLVM IR translation failed";
      return result;
    }
  } else {
    output = moduleToString(module);
  }
  
  // Write to file or return string
  if (!outputFile.empty()) {
    std::error_code ec;
    llvm::raw_fd_ostream outFile(outputFile, ec);
    if (ec) {
      result.success = false;
      result.errorMessage = "Failed to open output file: " + ec.message();
      return result;
    }
    outFile << output;
    outFile.flush();
  }
  
  result.success = true;
  result.output = output;
  return result;
}

LogicalResult NovaCompilerAPI::runPipeline(ModuleOp module, 
                                           const CompilerOptions &options) {
  // Create a PassManager that operates on ModuleOp
  PassManager pm(module->getName());
  
  if (options.verbose) {
    pm.enableIRPrinting();
  }
  
  if (options.runFullPipeline) {
    // Add the Nova optimization pipeline
    createNovaPipelines(pm);
  }
  
  // Run custom pipeline if specified
  if (!options.customPipeline.empty()) {
    if (failed(parsePassPipeline(options.customPipeline, pm))) {
      return failure();
    }
  }
  
  return pm.run(module);
}

std::string NovaCompilerAPI::translateToLLVMIR(ModuleOp module) {
  llvm::LLVMContext llvmContext;
  auto llvmModule = translateModuleToLLVMIR(module, llvmContext);
  if (!llvmModule) {
    return "";
  }
  
  std::string output;
  llvm::raw_string_ostream os(output);
  llvmModule->print(os, nullptr);
  os.flush();
  
  return output;
}

std::string NovaCompilerAPI::moduleToString(ModuleOp module) {
  std::string output;
  llvm::raw_string_ostream os(output);
  module.print(os);
  os.flush();
  return output;
}

//----------------------------------------------------------------------------//
// NovaCompilerSystemAPI Implementation
//----------------------------------------------------------------------------//

std::string NovaCompilerSystemAPI::executeCommand(const std::string &command) {
  std::array<char, 128> buffer;
  std::string result;
  
  FILE* pipe = popen(command.c_str(), "r");
  if (!pipe) {
    return "";
  }
  
  while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
    result += buffer.data();
  }
  
  pclose(pipe);
  return result;
}

std::string NovaCompilerSystemAPI::findNovaOpt(const std::string &hint) {
  if (!hint.empty()) {
    return hint;
  }
  
  // Try common locations
  std::vector<std::string> paths = {
    "./build/tools/nova-opt/nova-opt",
    "../build/tools/nova-opt/nova-opt",
    "nova-opt"  // In PATH
  };
  
  for (const auto &path : paths) {
    std::string cmd = "which " + path + " 2>/dev/null";
    std::string result = executeCommand(cmd);
    if (!result.empty()) {
      // Remove trailing newline
      if (!result.empty() && result.back() == '\n') {
        result.pop_back();
      }
      return result;
    }
  }
  
  return "nova-opt";  // Fallback to PATH
}

bool NovaCompilerSystemAPI::compileToLLVMIR(const std::string &inputFile,
                                            const std::string &outputFile,
                                            const std::string &novaOptPath) {
  std::string novaOpt = findNovaOpt(novaOptPath);
  
  // Build command: nova-opt | mlir-translate
  std::string cmd = novaOpt + " " + inputFile + " --nova-opt-pipeline | " +
                    "mlir-translate --mlir-to-llvmir > " + outputFile;
  
  int result = system(cmd.c_str());
  return result == 0;
}

bool NovaCompilerSystemAPI::compileToObject(const std::string &inputFile,
                                            const std::string &outputFile,
                                            const std::string &novaOptPath) {
  // First compile to LLVM IR
  std::string tempLL = outputFile + ".tmp.ll";
  if (!compileToLLVMIR(inputFile, tempLL, novaOptPath)) {
    return false;
  }
  
  // Then compile to object file
  std::string cmd = "llc " + tempLL + " -filetype=obj -o " + outputFile;
  int result = system(cmd.c_str());
  
  // Clean up temp file
  std::remove(tempLL.c_str());
  
  return result == 0;
}

std::string NovaCompilerSystemAPI::getLLVMIR(const std::string &inputFile,
                                             const std::string &novaOptPath) {
  std::string novaOpt = findNovaOpt(novaOptPath);
  
  // Build command
  std::string cmd = novaOpt + " " + inputFile + " --nova-opt-pipeline | " +
                    "mlir-translate --mlir-to-llvmir";
  
  return executeCommand(cmd);
}
