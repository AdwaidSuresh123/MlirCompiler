module {
  func.func @main(%arg0: tensor<4x3x2xf32>,%arg1:tensor<4x3x2xi64> ) -> tensor<4x3x2xf32> {
 %a =nova.gelu %arg0 : tensor<4x3x2xf32> 
  return %a :tensor<4x3x2xf32>
  }
}