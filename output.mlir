module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.mlir.global private constant @__constant_512x512xf32_0(dense<2.000000e+00> : tensor<512x512xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<512 x array<512 x f32>>
  llvm.mlir.global private constant @__constant_512x512xf32(dense<1.000000e+00> : tensor<512x512xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<512 x array<512 x f32>>
  llvm.func @matmul(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg7, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg8, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg9, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg10, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg12, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg11, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg13, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg0, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg1, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg2, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg3, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg5, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg4, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg6, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.constant(8 : index) : i64
    %17 = llvm.mlir.constant(1 : index) : i64
    %18 = llvm.mlir.constant(32 : index) : i64
    %19 = llvm.mlir.constant(512 : index) : i64
    %20 = llvm.mlir.constant(0 : index) : i64
    %21 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %22 = llvm.mlir.constant(512 : index) : i64
    %23 = llvm.mlir.constant(512 : index) : i64
    %24 = llvm.mlir.constant(1 : index) : i64
    %25 = llvm.mlir.constant(262144 : index) : i64
    %26 = llvm.mlir.zero : !llvm.ptr
    %27 = llvm.getelementptr %26[%25] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %28 = llvm.ptrtoint %27 : !llvm.ptr to i64
    %29 = llvm.mlir.constant(64 : index) : i64
    %30 = llvm.add %28, %29 : i64
    %31 = llvm.call @malloc(%30) : (i64) -> !llvm.ptr
    %32 = llvm.ptrtoint %31 : !llvm.ptr to i64
    %33 = llvm.mlir.constant(1 : index) : i64
    %34 = llvm.sub %29, %33 : i64
    %35 = llvm.add %32, %34 : i64
    %36 = llvm.urem %35, %29 : i64
    %37 = llvm.sub %35, %36 : i64
    %38 = llvm.inttoptr %37 : i64 to !llvm.ptr
    %39 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %40 = llvm.insertvalue %31, %39[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.insertvalue %38, %40[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.mlir.constant(0 : index) : i64
    %43 = llvm.insertvalue %42, %41[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.insertvalue %22, %43[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.insertvalue %23, %44[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.insertvalue %23, %45[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %24, %46[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%20 : i64)
  ^bb1(%48: i64):  // 2 preds: ^bb0, ^bb10
    %49 = llvm.icmp "slt" %48, %19 : i64
    llvm.cond_br %49, ^bb2(%20 : i64), ^bb11(%20 : i64)
  ^bb2(%50: i64):  // 2 preds: ^bb1, ^bb9
    %51 = llvm.icmp "slt" %50, %19 : i64
    llvm.cond_br %51, ^bb3, ^bb10
  ^bb3:  // pred: ^bb2
    %52 = llvm.add %48, %18 : i64
    llvm.br ^bb4(%48 : i64)
  ^bb4(%53: i64):  // 2 preds: ^bb3, ^bb8
    %54 = llvm.icmp "slt" %53, %52 : i64
    llvm.cond_br %54, ^bb5, ^bb9
  ^bb5:  // pred: ^bb4
    %55 = llvm.add %50, %18 : i64
    llvm.br ^bb6(%50 : i64)
  ^bb6(%56: i64):  // 2 preds: ^bb5, ^bb7
    %57 = llvm.icmp "slt" %56, %55 : i64
    llvm.cond_br %57, ^bb7, ^bb8
  ^bb7:  // pred: ^bb6
    %58 = llvm.extractvalue %47[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %59 = llvm.mlir.constant(512 : index) : i64
    %60 = llvm.mul %53, %59 overflow<nsw, nuw> : i64
    %61 = llvm.add %60, %56 overflow<nsw, nuw> : i64
    %62 = llvm.getelementptr inbounds|nuw %58[%61] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %21, %62 : f32, !llvm.ptr
    %63 = llvm.add %56, %17 : i64
    llvm.br ^bb6(%63 : i64)
  ^bb8:  // pred: ^bb6
    %64 = llvm.add %53, %17 : i64
    llvm.br ^bb4(%64 : i64)
  ^bb9:  // pred: ^bb4
    %65 = llvm.add %50, %18 : i64
    llvm.br ^bb2(%65 : i64)
  ^bb10:  // pred: ^bb2
    %66 = llvm.add %48, %18 : i64
    llvm.br ^bb1(%66 : i64)
  ^bb11(%67: i64):  // 2 preds: ^bb1, ^bb25
    %68 = llvm.icmp "slt" %67, %19 : i64
    llvm.cond_br %68, ^bb12(%20 : i64), ^bb26
  ^bb12(%69: i64):  // 2 preds: ^bb11, ^bb24
    %70 = llvm.icmp "slt" %69, %19 : i64
    llvm.cond_br %70, ^bb13(%20 : i64), ^bb25
  ^bb13(%71: i64):  // 2 preds: ^bb12, ^bb23
    %72 = llvm.icmp "slt" %71, %19 : i64
    llvm.cond_br %72, ^bb14, ^bb24
  ^bb14:  // pred: ^bb13
    %73 = llvm.add %67, %18 : i64
    llvm.br ^bb15(%67 : i64)
  ^bb15(%74: i64):  // 2 preds: ^bb14, ^bb22
    %75 = llvm.icmp "slt" %74, %73 : i64
    llvm.cond_br %75, ^bb16, ^bb23
  ^bb16:  // pred: ^bb15
    %76 = llvm.add %69, %18 : i64
    llvm.br ^bb17(%69 : i64)
  ^bb17(%77: i64):  // 2 preds: ^bb16, ^bb21
    %78 = llvm.icmp "slt" %77, %76 : i64
    llvm.cond_br %78, ^bb18, ^bb22
  ^bb18:  // pred: ^bb17
    %79 = llvm.add %71, %16 : i64
    llvm.br ^bb19(%71 : i64)
  ^bb19(%80: i64):  // 2 preds: ^bb18, ^bb20
    %81 = llvm.icmp "slt" %80, %79 : i64
    llvm.cond_br %81, ^bb20, ^bb21
  ^bb20:  // pred: ^bb19
    %82 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %83 = llvm.mlir.constant(512 : index) : i64
    %84 = llvm.mul %74, %83 overflow<nsw, nuw> : i64
    %85 = llvm.add %84, %80 overflow<nsw, nuw> : i64
    %86 = llvm.getelementptr inbounds|nuw %82[%85] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %87 = llvm.load %86 : !llvm.ptr -> f32
    %88 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %89 = llvm.mlir.constant(512 : index) : i64
    %90 = llvm.mul %80, %89 overflow<nsw, nuw> : i64
    %91 = llvm.add %90, %77 overflow<nsw, nuw> : i64
    %92 = llvm.getelementptr inbounds|nuw %88[%91] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %93 = llvm.load %92 : !llvm.ptr -> f32
    %94 = llvm.extractvalue %47[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %95 = llvm.mlir.constant(512 : index) : i64
    %96 = llvm.mul %74, %95 overflow<nsw, nuw> : i64
    %97 = llvm.add %96, %77 overflow<nsw, nuw> : i64
    %98 = llvm.getelementptr inbounds|nuw %94[%97] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %99 = llvm.load %98 : !llvm.ptr -> f32
    %100 = llvm.fmul %87, %93 : f32
    %101 = llvm.fadd %99, %100 : f32
    %102 = llvm.extractvalue %47[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %103 = llvm.mlir.constant(512 : index) : i64
    %104 = llvm.mul %74, %103 overflow<nsw, nuw> : i64
    %105 = llvm.add %104, %77 overflow<nsw, nuw> : i64
    %106 = llvm.getelementptr inbounds|nuw %102[%105] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %101, %106 : f32, !llvm.ptr
    %107 = llvm.add %80, %17 : i64
    llvm.br ^bb19(%107 : i64)
  ^bb21:  // pred: ^bb19
    %108 = llvm.add %77, %17 : i64
    llvm.br ^bb17(%108 : i64)
  ^bb22:  // pred: ^bb17
    %109 = llvm.add %74, %17 : i64
    llvm.br ^bb15(%109 : i64)
  ^bb23:  // pred: ^bb15
    %110 = llvm.add %71, %16 : i64
    llvm.br ^bb13(%110 : i64)
  ^bb24:  // pred: ^bb13
    %111 = llvm.add %69, %18 : i64
    llvm.br ^bb12(%111 : i64)
  ^bb25:  // pred: ^bb12
    %112 = llvm.add %67, %18 : i64
    llvm.br ^bb11(%112 : i64)
  ^bb26:  // pred: ^bb11
    llvm.return %47 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.constant(true) : i1
    %1 = llvm.mlir.constant(0 : index) : i64
    %2 = llvm.mlir.constant(1.024000e+03 : f32) : f32
    %3 = llvm.mlir.constant(512 : index) : i64
    %4 = llvm.mlir.constant(512 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.constant(262144 : index) : i64
    %7 = llvm.mlir.zero : !llvm.ptr
    %8 = llvm.getelementptr %7[%6] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %9 = llvm.ptrtoint %8 : !llvm.ptr to i64
    %10 = llvm.mlir.addressof @__constant_512x512xf32 : !llvm.ptr
    %11 = llvm.getelementptr %10[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<512 x array<512 x f32>>
    %12 = llvm.mlir.constant(3735928559 : index) : i64
    %13 = llvm.inttoptr %12 : i64 to !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %11, %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %3, %18[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %4, %19[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %4, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %5, %21[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.mlir.constant(512 : index) : i64
    %24 = llvm.mlir.constant(512 : index) : i64
    %25 = llvm.mlir.constant(1 : index) : i64
    %26 = llvm.mlir.constant(262144 : index) : i64
    %27 = llvm.mlir.zero : !llvm.ptr
    %28 = llvm.getelementptr %27[%26] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %29 = llvm.ptrtoint %28 : !llvm.ptr to i64
    %30 = llvm.mlir.addressof @__constant_512x512xf32_0 : !llvm.ptr
    %31 = llvm.getelementptr %30[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<512 x array<512 x f32>>
    %32 = llvm.mlir.constant(3735928559 : index) : i64
    %33 = llvm.inttoptr %32 : i64 to !llvm.ptr
    %34 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %35 = llvm.insertvalue %33, %34[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.insertvalue %31, %35[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.mlir.constant(0 : index) : i64
    %38 = llvm.insertvalue %37, %36[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.insertvalue %23, %38[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.insertvalue %24, %39[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.insertvalue %24, %40[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.insertvalue %25, %41[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.extractvalue %22[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %22[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %22[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %22[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.extractvalue %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.extractvalue %22[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.extractvalue %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.extractvalue %42[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.extractvalue %42[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.extractvalue %42[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.extractvalue %42[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.extractvalue %42[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %55 = llvm.extractvalue %42[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %56 = llvm.extractvalue %42[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %57 = llvm.call @matmul(%43, %44, %45, %46, %47, %48, %49, %50, %51, %52, %53, %54, %55, %56) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %58 = llvm.extractvalue %57[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %59 = llvm.mlir.constant(512 : index) : i64
    %60 = llvm.mul %1, %59 overflow<nsw, nuw> : i64
    %61 = llvm.add %60, %1 overflow<nsw, nuw> : i64
    %62 = llvm.getelementptr inbounds|nuw %58[%61] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %63 = llvm.load %62 : !llvm.ptr -> f32
    %64 = llvm.fcmp "oeq" %63, %2 : f32
    %65 = llvm.xor %64, %0 : i1
    %66 = llvm.zext %65 : i1 to i32
    %67 = llvm.extractvalue %57[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %68 = llvm.extractvalue %57[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %69 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %70 = llvm.insertvalue %67, %69[0] : !llvm.struct<(ptr, ptr, i64)> 
    %71 = llvm.insertvalue %68, %70[1] : !llvm.struct<(ptr, ptr, i64)> 
    %72 = llvm.mlir.constant(0 : index) : i64
    %73 = llvm.insertvalue %72, %71[2] : !llvm.struct<(ptr, ptr, i64)> 
    %74 = llvm.extractvalue %57[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %75 = llvm.extractvalue %57[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %76 = llvm.extractvalue %57[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %77 = llvm.extractvalue %57[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %78 = llvm.extractvalue %57[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %79 = llvm.extractvalue %73[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%79) : (!llvm.ptr) -> ()
    llvm.return %66 : i32
  }
}

