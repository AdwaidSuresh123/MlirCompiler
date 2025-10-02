module{
//test file
func.func @test_add(%arg0: tensor<2x2xf32>, %arg1: tensor<2x2xf32>) -> tensor<2x2xf32> {
  %0 = nova.add %arg0, %arg1 : tensor<2x2xf32>, tensor<2x2xf32>
  return %0 : tensor<2x2xf32>
}
func.func @test_negate(%arg0: tensor<2x2xf32>)->tensor<2x2xf32> {
  %0 = nova.negate %arg0 : tensor<2x2xf32>
  return %0 : tensor<2x2xf32>
}
}
