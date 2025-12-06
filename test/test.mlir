module {
  func.func @main(%arg0: tensor<2x4x4x3x2xf32>,%arg1:tensor<4x2x3xf32> ) -> tensor<2x4x4x3x3xf32> {
  %a =nova.matmul %arg0,%arg1 : tensor<2x4x4x3x2xf32>,tensor<4x2x3xf32> 
  return %a :tensor<2x4x4x3x3xf32>
  }
}