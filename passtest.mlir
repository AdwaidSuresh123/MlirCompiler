// RUN: nova-opt %s --canonicalize | FileCheck %s

// ============================================================================
// Test Identity Elimination Patterns
// ============================================================================

func.func @test_multiple_add(%arg0: tensor<f32>) -> (tensor<f32>, tensor<f32>) {
  %c1 = arith.constant dense<5.0> : tensor<f32>
  %c2 = arith.constant dense<3.0> : tensor<f32>
  %c3 = arith.constant dense<7.0> : tensor<f32>
  
  // Change to nova.add
  %a = nova.add %arg0, %c1 : tensor<f32>, tensor<f32> -> tensor<f32>
  %b = nova.add %a, %c2 : tensor<f32>, tensor<f32> -> tensor<f32>
  %d = nova.add %a, %c3 : tensor<f32>, tensor<f32> -> tensor<f32>
  return %b, %d : tensor<f32>, tensor<f32>
}



// Check emilinate add zero
func.func @test_add_zero(%arg0: tensor<10xi32>) -> tensor<10xi32> {
  %zero = arith.constant dense<0> : tensor<10xi32>
  %result = nova.add %arg0, %zero : tensor<10xi32>, tensor<10xi32> -> tensor<10xi32>
  return %result : tensor<10xi32>
}

// CHECK-LABEL: @test_add_zero_commutative
func.func @test_add_zero_commutative(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %zero = arith.constant dense<0.0> : tensor<10xf32>
  %result = nova.add %zero, %arg0 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}


func.func @test_sub_zero(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %zero = arith.constant dense<0.0> : tensor<10xf32>
  %result = nova.sub %arg0, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

func.func @test_sub_self(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %result = nova.sub %arg0, %arg0 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// CHECK-LABEL: @test_mul_one
func.func @test_mul_one(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %one = arith.constant dense<1.0> : tensor<10xf32>
  // CHECK-NOT: nova.mul
  // CHECK: return %arg0
  %result = nova.mul %arg0, %one : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// CHECK-LABEL: @test_mul_one_commutative
func.func @test_mul_one_commutative(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %one = arith.constant dense<1.0> : tensor<10xf32>
  %result = nova.mul %one, %arg0 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

func.func @test_mul_zero(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %zero = arith.constant dense<0.0> : tensor<10xf32>
  %result = nova.mul %arg0, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// CHECK-LABEL: @test_div_one
func.func @test_div_one(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %one = arith.constant dense<1.0> : tensor<10xf32>
  %result = nova.div %arg0, %one : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// ============================================================================
// Test Constant Combining Patterns
// ============================================================================


func.func @test_combine_add_constants(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %c2 = arith.constant dense<2.0> : tensor<10xf32>
  %c3 = arith.constant dense<3.0> : tensor<10xf32>
  %add1 = nova.add %arg0, %c2 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %add2 = nova.add %add1, %c3 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %add2 : tensor<10xf32>
}

// CHECK-LABEL: @test_combine_mul_constants
func.func @test_combine_mul_constants(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %c2 = arith.constant dense<2.0> : tensor<10xf32>
  %c3 = arith.constant dense<3.0> : tensor<10xf32>
  %mul1 = nova.mul %arg0, %c2 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %mul2 = nova.mul %mul1, %c3 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %mul2 : tensor<10xf32>
}

// ============================================================================
// Test Self-Operation Patterns
// ============================================================================

// CHECK-LABEL: @test_max_self
func.func @test_max_self(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %result = nova.max %arg0, %arg0 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

func.func @test_min_self(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %result = nova.min %arg0, %arg0 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// ============================================================================
// Test Broadcast Insertion
// ============================================================================

// CHECK-LABEL: @test_broadcast_insertion
func.func @test_broadcast_insertion(%arg0: tensor<10xf32>) -> tensor<2x10xf32> {
  %input = arith.constant dense<1.0> : tensor<2x10xf32>
  // CHECK: %[[BROADCAST:.*]] = nova.broadcast_in_dim %arg0, dims = [1]
  // CHECK: nova.add %[[BROADCAST]], %{{.*}}
  %result = nova.add %arg0, %input : tensor<10xf32>, tensor<2x10xf32> -> tensor<2x10xf32>
  return %result : tensor<2x10xf32>
}

// ============================================================================
// Test Combined Patterns (Multiple Optimizations)
// ============================================================================

// CHECK-LABEL: @test_combined_simplification
func.func @test_combined_simplification(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %zero = arith.constant dense<0.0> : tensor<10xf32>
  %one = arith.constant dense<1.0> : tensor<10xf32>
  %two = arith.constant dense<2.0> : tensor<10xf32>
  
  // Multiple operations that should simplify
  %r1 = nova.add %arg0, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %r2 = nova.mul %r1, %one : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %r3 = nova.sub %r2, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %r4 = nova.div %r3, %one : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  
  // CHECK-NOT: nova.add
  // CHECK-NOT: nova.mul
  // CHECK-NOT: nova.sub
  // CHECK-NOT: nova.div
  // CHECK: return %arg0
  return %r4 : tensor<10xf32>
}

// CHECK-LABEL: @test_chain_elimination
func.func @test_chain_elimination(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %c2 = arith.constant dense<2.0> : tensor<10xf32>
  %c3 = arith.constant dense<3.0> : tensor<10xf32>
  %c5 = arith.constant dense<5.0> : tensor<10xf32>
  
  // (A + 2) + 3 + 5 should become A + 10
  // CHECK: %[[C10:.*]] = arith.constant dense<1.000000e+01>
  %add1 = nova.add %arg0, %c2 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %add2 = nova.add %add1, %c3 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %add3 = nova.add %add2, %c5 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  // CHECK: %[[RESULT:.*]] = nova.add %arg0, %[[C10]]
  // CHECK: return %[[RESULT]]
  return %add3 : tensor<10xf32>
}

// ============================================================================
// Test No-Op Cases (Should NOT Simplify)
// ============================================================================

// CHECK-LABEL: @test_no_simplification_needed
func.func @test_no_simplification_needed(%arg0: tensor<10xf32>, %arg1: tensor<10xf32>) -> tensor<10xf32> {
  // CHECK: nova.add
  %result = nova.add %arg0, %arg1 : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// CHECK-LABEL: @test_mul_two
func.func @test_mul_two(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %two = arith.constant dense<2.0> : tensor<10xf32>
  // CHECK: nova.mul
  // Should NOT simplify (2.0 is not identity)
  %result = nova.mul %arg0, %two : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// ============================================================================
// Test Different Tensor Sizes
// ============================================================================

// CHECK-LABEL: @test_2d_tensor
func.func @test_2d_tensor(%arg0: tensor<3x4xf32>) -> tensor<3x4xf32> {
  %zero = arith.constant dense<0.0> : tensor<3x4xf32>
  // CHECK-NOT: nova.add
  // CHECK: return %arg0
  %result = nova.add %arg0, %zero : tensor<3x4xf32>, tensor<3x4xf32> -> tensor<3x4xf32>
  return %result : tensor<3x4xf32>
}

// CHECK-LABEL: @test_scalar_broadcast
func.func @test_scalar_broadcast(%arg0: tensor<f32>) -> tensor<10xf32> {
  %input = arith.constant dense<5.0> : tensor<10xf32>
  // CHECK: nova.broadcast_in_dim
  // CHECK: nova.add
  %result = nova.add %arg0, %input : tensor<f32>, tensor<10xf32> -> tensor<10xf32>
  return %result : tensor<10xf32>
}

// ============================================================================
// Test Complex Expressions
// ============================================================================

// CHECK-LABEL: @test_complex_expression
func.func @test_complex_expression(%arg0: tensor<10xf32>) -> tensor<10xf32> {
  %zero = arith.constant dense<0.0> : tensor<10xf32>
  %one = arith.constant dense<1.0> : tensor<10xf32>
  
  // (A * 1) + 0 - 0 should simplify to A
  %mul = nova.mul %arg0, %one : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %add = nova.add %mul, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  %sub = nova.sub %add, %zero : tensor<10xf32>, tensor<10xf32> -> tensor<10xf32>
  
  // CHECK-NOT: nova.mul
  // CHECK-NOT: nova.add
  // CHECK-NOT: nova.sub
  // CHECK: return %arg0
  return %sub : tensor<10xf32>
}