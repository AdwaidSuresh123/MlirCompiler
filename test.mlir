func.func @matmul_test(%arg0: tensor<2x4xf32>, %arg1: tensor<4x4xf32>,%arg2:tensor<1x4xf32>) -> tensor<2x4xf32> {

  %result = nova.matmul %arg0, %arg1 : tensor<2x4xf32>, tensor<4x4xf32>
  %1=nova.add %arg0 ,%arg2 : tensor<2x4xf32>,tensor<1x4xf32>

  %resi=nova.relu %result :tensor<2x4xf32>
  return %1 : tensor<2x4xf32>
}