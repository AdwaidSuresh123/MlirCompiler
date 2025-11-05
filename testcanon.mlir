func.func @matmul_test(%arg0: tensor<2x4xf32>, %arg1: tensor<4x4xf32>) -> tensor<2x4xf32> {
  %result = nova.matmul %arg0, %arg1 : tensor<2x4xf32>, tensor<4x4xf32>
  return %result : tensor<2x4xf32>
}