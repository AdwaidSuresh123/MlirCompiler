func.func @main(%input1: tensor<4096x4096xf32>, 
                %input2: tensor<4096x4096xf32>,
                %input3: tensor<4096xf32>) -> tensor<1xf32> {
  %A = nova.constant {value = dense<[1.0]> : tensor<1xf32>} : tensor<1xf32>
  return %A : tensor<1xf32>
}
// convert-nova-to-tosa --convert-nova-to-linalg --convert-nova-to-arith 