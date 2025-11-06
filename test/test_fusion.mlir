func.func @matmul_with_bias(%A: tensor<128x256xf32>, %B: tensor<256x512xf32>, %bias: tensor<128x512xf32>) -> tensor<128x512xf32> {
  // Matrix multiplication
  %init = tensor.empty() : tensor<128x512xf32>
  %zero = arith.constant 0.0 : f32
  %init_filled = linalg.fill ins(%zero : f32) outs(%init : tensor<128x512xf32>) -> tensor<128x512xf32>

  %matmul = linalg.matmul
    ins(%A, %B : tensor<128x256xf32>, tensor<256x512xf32>)
    outs(%init_filled : tensor<128x512xf32>) -> tensor<128x512xf32>

  // Add bias (this should be fused with matmul!)
  %result = linalg.add
    ins(%matmul, %bias : tensor<128x512xf32>, tensor<128x512xf32>)
    outs(%init : tensor<128x512xf32>) -> tensor<128x512xf32>

  return %result : tensor<128x512xf32>
}
