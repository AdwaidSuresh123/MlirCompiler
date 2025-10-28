// example.mlir
func.func @main( %arg0:tensor<4xf32>)->  tensor<4xf32>{
  %zw=nova.relu %arg0 :tensor<4xf32>
  func.return %zw: tensor<4xf32>
}
