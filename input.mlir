module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.mlir.global private constant @__constant_4xf32(dense<0.000000e+00> : tensor<4xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<4 x f32>
  llvm.func @main(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> {
    %0 = llvm.mlir.constant(64 : index) : i64
    %1 = llvm.mlir.addressof @__constant_4xf32 : !llvm.ptr
    %2 = llvm.mlir.zero : !llvm.ptr
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.mlir.constant(4 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %7 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<4 x f32>
    %8 = llvm.getelementptr %2[4] : (!llvm.ptr) -> !llvm.ptr, f32
    %9 = llvm.ptrtoint %8 : !llvm.ptr to i64
    %10 = llvm.add %9, %0 : i64
    %11 = llvm.call @malloc(%10) : (i64) -> !llvm.ptr
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.sub %0, %5 : i64
    %14 = llvm.add %12, %13 : i64
    %15 = llvm.urem %14, %0 : i64
    %16 = llvm.sub %14, %15 : i64
    %17 = llvm.inttoptr %16 : i64 to !llvm.ptr
    llvm.br ^bb1(%3 : i64)
  ^bb1(%18: i64):  // 2 preds: ^bb0, ^bb2
    %19 = llvm.icmp "slt" %18, %4 : i64
    llvm.cond_br %19, ^bb2, ^bb3(%3 : i64)
  ^bb2:  // pred: ^bb1
    %20 = llvm.getelementptr inbounds|nuw %arg1[%18] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %21 = llvm.load %20 : !llvm.ptr -> f32
    %22 = llvm.getelementptr inbounds|nuw %7[%18] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %23 = llvm.load %22 : !llvm.ptr -> f32
    %24 = llvm.intr.maximum(%21, %23) : (f32, f32) -> f32
    %25 = llvm.getelementptr inbounds|nuw %17[%18] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %24, %25 : f32, !llvm.ptr
    %26 = llvm.add %18, %5 : i64
    llvm.br ^bb1(%26 : i64)
  ^bb3(%27: i64):  // 2 preds: ^bb1, ^bb4
    %28 = llvm.icmp "slt" %27, %4 : i64
    llvm.cond_br %28, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %29 = llvm.getelementptr inbounds|nuw %arg1[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %30 = llvm.load %29 : !llvm.ptr -> f32
    %31 = llvm.getelementptr inbounds|nuw %17[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %32 = llvm.load %31 : !llvm.ptr -> f32
    %33 = llvm.fadd %30, %32 : f32
    %34 = llvm.getelementptr inbounds|nuw %arg1[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %33, %34 : f32, !llvm.ptr
    %35 = llvm.add %27, %5 : i64
    llvm.br ^bb3(%35 : i64)
  ^bb5:  // pred: ^bb3
    %36 = llvm.getelementptr %2[4] : (!llvm.ptr) -> !llvm.ptr, f32
    %37 = llvm.ptrtoint %36 : !llvm.ptr to i64
    %38 = llvm.call @malloc(%37) : (i64) -> !llvm.ptr
    %39 = llvm.insertvalue %38, %6[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %40 = llvm.insertvalue %38, %39[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %41 = llvm.insertvalue %3, %40[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %42 = llvm.insertvalue %4, %41[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %43 = llvm.insertvalue %5, %42[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %44 = llvm.mul %arg3, %5 : i64
    %45 = llvm.getelementptr %2[1] : (!llvm.ptr) -> !llvm.ptr, f32
    %46 = llvm.ptrtoint %45 : !llvm.ptr to i64
    %47 = llvm.mul %44, %46 : i64
    %48 = llvm.getelementptr %arg1[%arg2] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    "llvm.intr.memcpy"(%38, %48, %47) <{isVolatile = false}> : (!llvm.ptr, !llvm.ptr, i64) -> ()
    llvm.call @free(%11) : (!llvm.ptr) -> ()
    llvm.return %43 : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
  }
}

