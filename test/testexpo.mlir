module {
  func.func @main(%arg0: tensor<4x3x2xcomplex<f32>>,%arg1:tensor<4x3x2xcomplex<f32>> ) -> tensor<4x3x2xcomplex<f32>> {
  %a =nova.mod %arg0,%arg1 : tensor<4x3x2xcomplex<f32>>,tensor<4x3x2xcomplex<f32>> 
  return %a :tensor<4x3x2xcomplex<f32>>
  }
}