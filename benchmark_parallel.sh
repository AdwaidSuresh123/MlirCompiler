#!/bin/bash

echo "=== MLIR Parallelized Matmul Benchmark ==="
echo "Sequential (vectorized only):"
{ time -p for i in {1..30}; do ./matmul > /dev/null; done; } 2>&1 | grep real

echo ""
echo "Parallel (vectorized + OpenMP):"
{ time -p for i in {1..30}; do ./matmul_mlir_parallel > /dev/null; done; } 2>&1 | grep real
