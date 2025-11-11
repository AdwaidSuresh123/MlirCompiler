// Test with small matrices first
// Change your test2.mlir to use 8x8 matrices temporarily
func.func @core_op(%A: tensor<8x8xf32>, %B: tensor<8x8xf32>) -> tensor<8x8xf32> {
  %m_result = nova.matmul %A, %B : tensor<8x8xf32>, tensor<8x8xf32>
  return %m_result : tensor<8x8xf32>
}