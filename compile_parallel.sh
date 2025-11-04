#!/bin/bash
set -e

echo "=== Compiling with OpenMP parallelization ==="

# Step 1: Generate optimized MLIR with tiling
echo "Step 1: Generating tiled MLIR..."
./build/tools/nova-opt/nova-opt test.mlir \
  --pass-pipeline='builtin.module(
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
  )' -o output_vectorized.mlir

# Step 2: Convert to LLVM IR
echo "Step 2: Converting to LLVM IR..."
~/Desktop/llvm-project/build/bin/mlir-translate output_vectorized.mlir \
  --mlir-to-llvmir -o output_vectorized.ll

# Step 3: Optimize with LLVM (with Polly if available)
echo "Step 3: Optimizing LLVM IR..."
~/Desktop/llvm-project/build/bin/opt output_vectorized.ll -o output_opt.ll \
  -passes="default<O3>" \
  -fp-contract=fast \
  -enable-unsafe-fp-math

# Step 4: Compile to assembly
echo "Step 4: Generating assembly..."
llc output_opt.ll -o output_opt.s \
  -O3 \
  -march=x86-64 \
  -mcpu=native \
  -mattr=+avx2,+fma \
  -filetype=asm \
  -relocation-model=pic

# Step 5: Link with OpenMP runtime
echo "Step 5: Linking..."
clang output_opt.s -o matmul_final \
  -O3 \
  -ffast-math \
  -march=native \
  -mtune=native \
  -fopenmp \
  -pthread

echo "=== Compilation complete! ==="
echo "Sequential binary: ./matmul"
echo "Optimized binary: ./matmul_final"

echo ""
echo "=== Benchmarking ==="
echo "Testing sequential version..."
time ./matmul

echo ""
echo "Testing optimized version..."
time ./matmul_final
