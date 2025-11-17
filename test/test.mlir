func.func @main(%input1: tensor<4096x4096xi32>, 
                %input2: tensor<4096x4096xi32>,
                %input3: tensor<4096xf32>) -> tensor<4096x4096xi32> {
  %F = nova.and %input1, %input2: tensor<4096x4096xi32>, tensor<4096x4096xi32>
  %A = nova.or %F, %input2: tensor<4096x4096xi32>, tensor<4096x4096xi32>
  %B = nova.xor %A, %input2: tensor<4096x4096xi32>, tensor<4096x4096xi32>

  return %B : tensor<4096x4096xi32>
}
// convert-nova-to-tosa --convert-nova-to-linalg --convert-nova-to-arith 