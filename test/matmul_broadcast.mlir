
func.func @matmul_broadcast_simple(%arg0: tensor<2x3x4xf32>, %arg1: tensor<2x4x5xf32>) -> tensor<2x3x5xf32> {
  %0 = nova.matmul %arg0, %arg1 : tensor<2x3x4xf32>, tensor<2x4x5xf32>
  return %0 : tensor<2x3x5xf32>
}

func.func @matmul_broadcast_1(%arg0: tensor<1x3x4xf32>, %arg1: tensor<2x4x5xf32>) -> tensor<2x3x5xf32> {
  %0 = nova.matmul %arg0, %arg1 : tensor<1x3x4xf32>, tensor<2x4x5xf32>
  return %0 : tensor<2x3x5xf32>
}

func.func @matmul_broadcast_rank_diff(%arg0: tensor<3x4xf32>, %arg1: tensor<2x4x5xf32>) -> tensor<2x3x5xf32> {
  %0 = nova.matmul %arg0, %arg1 : tensor<3x4xf32>, tensor<2x4x5xf32>
  return %0 : tensor<2x3x5xf32>
}

func.func @matmul_broadcast_rank_diff_2(%arg0: tensor<2x3x4xf32>, %arg1: tensor<4x5xf32>) -> tensor<2x3x5xf32> {
  %0 = nova.matmul %arg0, %arg1 : tensor<2x3x4xf32>, tensor<4x5xf32>
  return %0 : tensor<2x3x5xf32>
}
