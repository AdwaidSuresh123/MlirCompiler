module {
  func.func @main(%arg0: tensor<4x3x2xi64>, %arg1: tensor<4x3x2xf32>) -> tensor<4x3x2xf64> {
    %a = nova.mod %arg0, %arg1 : tensor<4x3x2xi64>, tensor<4x3x2xf32>
    return %a : tensor<4x3x2xf64>
  }
}
