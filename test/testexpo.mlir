module {
  func.func @main(%arg0: tensor<4x3x2xf32>) -> tensor<4x2xi32> {
 
%0 = tosa.argmax %arg0 {axis = 1 : i32} : (tensor<4x3x2xf32>) -> tensor<4x2xi32>
     return %0 : tensor<4x2xi32>
  }
}