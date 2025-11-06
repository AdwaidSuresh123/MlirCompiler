module {
  // Declare external timing functions
  func.func private @get_time() -> i64
  func.func private @print_time(%val: i64)
  
  func.func @matmul(%A: tensor<512x512xf32>, 
                    %B: tensor<512x512xf32>) -> tensor<512x512xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %init = tensor.empty() : tensor<512x512xf32>
    %C = linalg.fill ins(%cst : f32) outs(%init : tensor<512x512xf32>) -> tensor<512x512xf32>
    
    // START TIMING - only the matmul computation
    %start = call @get_time() : () -> i64
    
    %result = linalg.matmul ins(%A, %B : tensor<512x512xf32>, tensor<512x512xf32>)
                           outs(%C : tensor<512x512xf32>) -> tensor<512x512xf32>
    
    // END TIMING
    %end = call @get_time() : () -> i64
    %duration = arith.subi %end, %start : i64
    call @print_time(%duration) : (i64) -> ()
    
    return %result : tensor<512x512xf32>
  }

  func.func @main() -> i32 {
    // Create input tensors
    %cst_0 = arith.constant 1.000000e+00 : f32
    %cst_1 = arith.constant 2.000000e+00 : f32
    %expected = arith.constant 1024.000000e+00 : f32
    
    %A = tensor.splat %cst_0 : tensor<512x512xf32>
    %B = tensor.splat %cst_1 : tensor<512x512xf32>
    
    // Call matmul (timing happens inside)
    %result = call @matmul(%A, %B) : (tensor<512x512xf32>, tensor<512x512xf32>) -> tensor<512x512xf32>

    // Verify result
    %c0 = arith.constant 0 : index
    %first_element = tensor.extract %result[%c0, %c0] : tensor<512x512xf32>
    %is_correct = arith.cmpf "oeq", %first_element, %expected : f32
    %success = arith.constant 0 : i32
    %failure = arith.constant 1 : i32
    %ret = arith.select %is_correct, %success, %failure : i32

    return %ret : i32
  }
}