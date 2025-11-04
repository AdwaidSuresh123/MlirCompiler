#!/bin/bash
set -e

echo "========================================="
echo "   Compiling with Parallelization"
echo "========================================="

# Strategy: Lower affine AFTER parallelization to avoid affine/scf conflicts
./build/tools/nova-opt/nova-opt test.mlir --pass-pipeline='builtin.module(
    canonicalize,
    one-shot-bufferize{
      bufferize-function-boundaries=1
      function-boundary-type-conversion=identity-layout-map
    },
    buffer-deallocation-pipeline,
    convert-linalg-to-affine-loops,
    func.func(
      affine-loop-tile{tile-sizes=64,64,8},
      affine-loop-unroll-jam{unroll-jam-factor=2}
    ),
    func.func(parallelize-outer-loops),
    lower-affine,
    convert-scf-to-openmp,
    func.func(
      canonicalize,
      cse
    ),
    convert-scf-to-cf,
    canonicalize,
    convert-math-to-llvm,
    convert-openmp-to-llvm,
    convert-cf-to-llvm,
    convert-arith-to-llvm,
    finalize-memref-to-llvm,
    convert-func-to-llvm,
    reconcile-unrealized-casts
  )' -o output_parallel.mlir

echo ""
echo "Step 2: Translate to LLVM IR..."
~/Desktop/llvm-project/build/bin/mlir-translate output_parallel.mlir \
  --mlir-to-llvmir -o output_parallel.ll

echo "Step 3: Compile to assembly..."
llc output_parallel.ll -o output_parallel.s \
  -O3 \
  -march=x86-64 \
  -mcpu=native \
  -mattr=+avx2,+fma \
  -filetype=asm \
  -relocation-model=pic

echo "Step 4: Link with OpenMP..."
clang output_parallel.s -o matmul_parallel \
  -O3 \
  -ffast-math \
  -march=native \
  -fopenmp \
  -pthread

echo ""
echo "========================================="
echo "   Build Complete!"
echo "========================================="
echo "Sequential: ./matmul"
echo "Parallel:   ./matmul_parallel"
echo ""
echo "Run with: OMP_NUM_THREADS=16 ./matmul_parallel"
