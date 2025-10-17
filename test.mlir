module {
  func.func @matmul(%A: tensor<512x512xf32>, 
                    %B: tensor<512x512xf32>) -> tensor<512x512xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %init = tensor.empty() : tensor<512x512xf32>
    %C = linalg.fill ins(%cst : f32) outs(%init : tensor<512x512xf32>) -> tensor<512x512xf32>
    %result = linalg.matmul ins(%A, %B : tensor<512x512xf32>, tensor<512x512xf32>)
                           outs(%C : tensor<512x512xf32>) -> tensor<512x512xf32>
    return %result : tensor<512x512xf32>
  }

  func.func @main() -> i32 {
    // Create input tensors
    %cst_0 = arith.constant 1.000000e+00 : f32
    %cst_1 = arith.constant 2.000000e+00 : f32
    %expected = arith.constant 1024.000000e+00 : f32  // 128 * 2.0
    
    %A = tensor.splat %cst_0 : tensor<512x512xf32>
    %B = tensor.splat %cst_1 : tensor<512x512xf32>
    
    // Call matmul
    %result = call @matmul(%A, %B) : (tensor<512x512xf32>, tensor<512x512xf32>) -> tensor<512x512xf32>

    // Verify result instead of printing
    %c0 = arith.constant 0 : index
    %first_element = tensor.extract %result[%c0, %c0] : tensor<512x512xf32>
    
    // Check if result is correct (1024.0)
    %is_correct = arith.cmpf "oeq", %first_element, %expected : f32
    
    // Return 0 if correct, 1 if wrong
    %success = arith.constant 0 : i32
    %failure = arith.constant 1 : i32
    %ret = arith.select %is_correct, %success, %failure : i32

    return %ret : i32
  }
}