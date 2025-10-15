// test_with_main.mlir
module {
  func.func @matmul(%A: tensor<128x128xf32>, 
                    %B: tensor<128x128xf32>) -> tensor<128x128xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %init = tensor.empty() : tensor<128x128xf32>
    %C = linalg.fill ins(%cst : f32) outs(%init : tensor<128x128xf32>) -> tensor<128x128xf32>
    %result = linalg.matmul ins(%A, %B : tensor<128x128xf32>, tensor<128x128xf32>)
                           outs(%C : tensor<128x128xf32>) -> tensor<128x128xf32>
    return %result : tensor<128x128xf32>
  }

  func.func @main() -> i32 {
    // Create input tensors
    %cst_0 = arith.constant 1.000000e+00 : f32
    %cst_1 = arith.constant 2.000000e+00 : f32
    
    %A = tensor.splat %cst_0 : tensor<128x128xf32>
    %B = tensor.splat %cst_1 : tensor<128x128xf32>
    
    // Call matmul
    %result = call @matmul(%A, %B) : (tensor<128x128xf32>, tensor<128x128xf32>) -> tensor<128x128xf32>
    
    // Return success
    %ret = arith.constant 0 : i32
    return %ret : i32
  }
}