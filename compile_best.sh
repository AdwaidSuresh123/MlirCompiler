#!/bin/bash
set -e

echo "========================================="
echo "   Optimized MLIR Compilation Pipeline"
echo "========================================="
echo ""

# Configuration
NOVA_OPT="./build/tools/nova-opt/nova-opt"
MLIR_TRANSLATE="$HOME/Desktop/llvm-project/build/bin/mlir-translate"

echo "Step 1: MLIR optimization passes..."
$NOVA_OPT test.mlir --pass-pipeline='builtin.module(
    canonicalize,
    one-shot-bufferize{
      bufferize-function-boundaries=1
      function-boundary-type-conversion=identity-layout-map
    },
    buffer-deallocation-pipeline,
    convert-linalg-to-affine-loops,
    func.func(
      affine-loop-tile{tile-sizes=32,32,8},
      affine-loop-unroll-jam{unroll-jam-factor=2},
      affine-loop-unroll{unroll-factor=8},
      canonicalize,
      cse,
      math-uplift-to-fma,
      affine-super-vectorize{virtual-vector-size=8},
      canonicalize
    ),
    lower-affine,
    convert-vector-to-scf,
    lower-affine,
    convert-scf-to-cf,
    canonicalize,
    convert-vector-to-llvm{enable-x86vector=true reassociate-fp-reductions=true},
    convert-math-to-llvm,
    convert-cf-to-llvm,
    convert-arith-to-llvm,
    finalize-memref-to-llvm,
    convert-func-to-llvm,
    cleanup,
    reconcile-unrealized-casts
  )' -o output.mlir

echo "Step 2: MLIR to LLVM IR..."
$MLIR_TRANSLATE output.mlir --mlir-to-llvmir -o output.ll

echo "Step 3: LLVM optimization..."
~/Desktop/llvm-project/build/bin/opt output.ll -o output_opt.ll \
  -passes="default<O3>" \
  -fp-contract=fast \
  -enable-unsafe-fp-math \
  -enable-no-nans-fp-math \
  -enable-no-signed-zeros-fp-math

echo "Step 4: Code generation..."
llc output_opt.ll -o output.s \
  -O3 \
  -march=x86-64 \
  -mcpu=native \
  -mattr=+avx2,+fma \
  -filetype=asm \
  -relocation-model=pic

echo "Step 5: Linking..."
clang output.s -o matmul \
  -O3 \
  -ffast-math \
  -march=native \
  -mtune=native

echo ""
echo "========================================="
echo "   Compilation Complete!"
echo "========================================="
echo "Sequential (vectorized): ./matmul"
echo "Parallel (OpenMP):       ./matmul_omp"
echo ""
echo "To benchmark, run: ./benchmark.sh"
