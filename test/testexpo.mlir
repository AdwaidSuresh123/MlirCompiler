module {
  func.func @main(%arg0: tensor<4096x4096xi32>, %arg1: tensor<4096x4096xi32>) -> tensor<4096x4096xi32> {
    %1 = arith.addi %arg0 ,%arg1: tensor<4096x4096xi32>

    return %1 : tensor<4096x4096xi32>
  }
}