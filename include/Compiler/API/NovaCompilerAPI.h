//===- NovaCompilerAPI.h - C++ API for Nova Compiler -----------*- C++ -*-===//
//
// Nova Compiler C++ API
// Provides programmatic access to the Nova MLIR compiler pipeline
//
//===----------------------------------------------------------------------===//

#ifndef NOVA_COMPILER_API_H
#define NOVA_COMPILER_API_H

#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/OwningOpRef.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/PassManager.h"
#include "llvm/Support/raw_ostream.h"
#include <string>
#include <memory>

namespace mlir {
namespace nova {

// Options for the Nova compiler
struct CompilerOptions {
  // Whether to run the full nova-opt-pipeline
  bool runFullPipeline = true;
  
  // Whether to output LLVM IR instead of LLVM dialect
  bool outputLLVMIR = false;
  
  // Additional pass pipeline string (optional)
  std::string customPipeline;
  
  // Enable verbose output
  bool verbose = false;
};

// Result of compilation
struct CompilationResult {
  // Whether compilation succeeded
  bool success = false;
  
  // Error message if compilation failed
  std::string errorMessage;
  
  // Output (LLVM IR or MLIR as string)
  std::string output;
};

// Main API class for Nova Compiler
class NovaCompilerAPI {
public:
  // Constructor
  NovaCompilerAPI();
  
  // Destructor
  ~NovaCompilerAPI();
  
  // Compile MLIR file to LLVM IR or LLVM dialect
  // inputFile Path to input .mlir file
  // outputFile Path to output file 
  CompilationResult compileFile(const std::string &inputFile,
                                const std::string &outputFile = "",
                                const CompilerOptions &options = CompilerOptions());
  
  // Compile MLIR string to LLVM IR or LLVM dialect
  // mlirSource MLIR source code as string
  // outputFile Path to output file 
  CompilationResult compileString(const std::string &mlirSource,
                                  const std::string &outputFile = "",
                                  const CompilerOptions &options = CompilerOptions());
  
  // Compile MLIR module to LLVM IR or LLVM dialect
  // module MLIR module operation
  // outputFile Path to output file 
  CompilationResult compileModule(mlir::ModuleOp module,
                                  const std::string &outputFile = "",
                                  const CompilerOptions &options = CompilerOptions());

private:
  // MLIR context
  std::unique_ptr<mlir::MLIRContext> context;
  
  // Run the Nova optimization pipeline
  mlir::LogicalResult runPipeline(mlir::ModuleOp module, 
                                  const CompilerOptions &options);
  
  // Translate MLIR to LLVM IR
  std::string translateToLLVMIR(mlir::ModuleOp module);
  
  // Convert module to string
  std::string moduleToString(mlir::ModuleOp module);
};

// Simple system-call based API (easier to use, but spawns processes)
class NovaCompilerSystemAPI {
public:
  // Compile MLIR file to LLVM IR using system calls
  // inputFile Path to input .mlir file
  // outputFile Path to output .ll file
  // novaOptPath Path to nova-opt 
  static bool compileToLLVMIR(const std::string &inputFile,
                              const std::string &outputFile,
                              const std::string &novaOptPath = "");
  
  // Compile MLIR file to object file using system calls
  // inputFile Path to input .mlir file
  // outputFile Path to output .o file
  // novaOptPath Path to nova-opt 
  static bool compileToObject(const std::string &inputFile,
                              const std::string &outputFile,
                              const std::string &novaOptPath = "");
  
  // Get LLVM IR as string
  // inputFile Path to input .mlir file
  // novaOptPath Path to nova-opt binary (optional)
  // return LLVM IR as string, or empty string on error
  static std::string getLLVMIR(const std::string &inputFile,
                               const std::string &novaOptPath = "");

private:
  // Execute command and capture output
  static std::string executeCommand(const std::string &command);
  
  // Find nova-opt binary
  static std::string findNovaOpt(const std::string &hint = "");
};

} // namespace nova
} // namespace mlir

#endif // NOVA_COMPILER_API_H
