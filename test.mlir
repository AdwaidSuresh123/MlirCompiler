
  // Test 2: Complex expression: (a + b) * (c - d)//
  func.func @test_complex_expr(%a: tensor<2x3xf32>, %b: tensor<3xf32>, 
                                %c: tensor<2x3xf32>, %d: tensor<3xf32>) -> tensor<2x3xf32> {
    %0 = nova.add %a, %b : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
    %1 = nova.sub %c, %d : tensor<2x3xf32>, tensor<3xf32> -> tensor<2x3xf32>
    %2 = nova.mul %0, %1 : tensor<2x3xf32>, tensor<2x3xf32> -> tensor<2x3xf32>
    return %2 : tensor<2x3xf32>
  }
