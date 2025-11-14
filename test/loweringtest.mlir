func.func @main(%input1: tensor<4096x4096xf32>, 
                %input2: tensor<4096x4096xf32>,
                %input3: tensor<4096xf32>) -> tensor<4096x4096xf32> {
  %A = nova.constant {value = dense<[1.0]> : tensor<1xf32>} : tensor<1xf32>
  %B = nova.matmul %input1, %input2 : tensor<4096x4096xf32>, tensor<4096x4096xf32>
  %C = nova.sub %B, %input3 : tensor<4096x4096xf32>, tensor<4096xf32>
  %D= nova.add %B, %C: tensor<4096x4096xf32>, tensor<4096x4096xf32>
  %E = nova.mul %D, %C: tensor<4096x4096xf32>, tensor<4096x4096xf32>
  %F = nova.pow %D, %A: tensor<4096x4096xf32>, tensor<1xf32>
  %G = nova.sin  %E: tensor<4096x4096xf32>
  %H = nova.abs  %F: tensor<4096x4096xf32>
  %I = nova.relu %G:tensor<4096x4096xf32>
  %J=nova.div %H,%I:tensor<4096x4096xf32>,tensor<4096x4096xf32>
  %K=nova.mod %I,%J:tensor<4096x4096xf32>,tensor<4096x4096xf32>
  %L=nova.max %J,%K:tensor<4096x4096xf32>,tensor<4096x4096xf32>
  %M=nova.min %K,%L:tensor<4096x4096xf32>,tensor<4096x4096xf32>
  return %M : tensor<4096x4096xf32>
}
// convert-nova-to-tosa --convert-nova-to-linalg --convert-nova-to-arith 