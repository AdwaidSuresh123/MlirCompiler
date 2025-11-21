module {
  func.func @main(%arg0: tensor<4096x4096xf32>, %arg1: tensor<4096x4096xi32>) -> tensor<4096x4096xf32> {
    %0 = nova.exp %arg1 : tensor<4096x4096xi32>
    %1 = nova.exp2 %arg1 : tensor<4096x4096xi32>
    %2 = nova.log %arg1 : tensor<4096x4096xi32>
    %3 = nova.log2 %arg1 : tensor<4096x4096xi32>
    %4 = nova.log10 %arg1 : tensor<4096x4096xi32>
    return %0 : tensor<4096x4096xf32>
  }
}