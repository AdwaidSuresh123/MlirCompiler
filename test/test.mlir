module {
  func.func @main(%arg0: tensor<4x3xi32>) -> tensor<3xi32> {
 
%0=nova.argmax %arg0 dimension = 0 :tensor<4x3xi32>
     return %0 : tensor<3xi32>
  }
}
