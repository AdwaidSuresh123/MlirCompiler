func.func @test_cancel_transpose_transpose(%arg0: tensor<2x2x2x2xf32> , %arg1: tensor<2x2x2x2xf32>,%arg2: tensor<2x2x2x2xf32> ) 
-> (tensor<2x2x2x2x
f32>) {
	%1 = nova.matmul %arg0, %arg1:tensor<2x2x2x2xf32> , tensor<2x2x2x2xf32> 
  %2 = nova.add %1, %arg2 : tensor<2x2x2x2xf32> ,tensor<2x2x2x2xf32>
  return %2 : tensor<2x2x2x2xf32>
}