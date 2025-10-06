module {
  func.func @test_broadcast(%arg0: tensor<3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
    %0 = nova.add %arg1, %arg0 : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
    return %0 : tensor<2x3xf32>
  }
  
  func.func @test_explicit_broadcast(%arg0: tensor<3xf32>) -> tensor<2x3xf32> {
    %0 = nova.broadcast_in_dim %arg0, dims = [1] : (tensor<3xf32>) -> tensor<2x3xf32>
    return %0 : tensor<2x3xf32>
  }
}