module {
  func.func @main(%arg0: tensor<4x3x2xf32>) -> tensor<1x1x1xi32> {
 
%0=nova.argmin %arg0  keepdims=true ignore_nan=true:tensor<4x3x2xf32>
     return %0 : tensor<1x1x1xi32>
  }
}
