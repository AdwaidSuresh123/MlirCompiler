

  // Test 2: Broadcast scalar-like (rank 1) to rank 2
  func.func @test_broadcast_rank1(%arg0: tensor<2x3xf32>, %arg1: tensor<3xf32>) -> tensor<2x3xf32> {
    %0 = nova.add %arg0, %arg1 : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
    return %0 : tensor<2x3xf32>
  }

 
