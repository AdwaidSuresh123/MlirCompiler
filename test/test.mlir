module {
  func.func @main(%arg0: tensor<4096x4096xf32>, %arg1: tensor<4096x4096xi32>) -> tensor<4096x4096xf32> {
    %1 = nova.exp %arg1 : tensor<4096x4096xi32>
    %2 = nova.exp2 %arg1 : tensor<4096x4096xi32>

    return %1 : tensor<4096x4096xf32>
  }
}