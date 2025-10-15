module {
  llvm.func @malloc(i64) -> !llvm.ptr
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
    %16 = llvm.mlir.undef : vector<8xf32>
    %17 = llvm.mlir.constant(dense<[0, 1, 2, 3, 4, 5, 6, 7]> : vector<8xi32>) : vector<8xi32>
    %18 = llvm.mlir.constant(32 : index) : i64
    %19 = llvm.mlir.constant(dense<0.000000e+00> : vector<8xf32>) : vector<8xf32>
    %20 = llvm.mlir.constant(8 : index) : i64
    %21 = llvm.mlir.constant(1 : index) : i64
    %22 = llvm.mlir.constant(64 : index) : i64
    %23 = llvm.mlir.constant(128 : index) : i64
    %24 = llvm.mlir.constant(0 : index) : i64
    %25 = llvm.mlir.constant(128 : index) : i64
    %26 = llvm.mlir.constant(128 : index) : i64
    %27 = llvm.mlir.constant(1 : index) : i64
    %28 = llvm.mlir.constant(16384 : index) : i64
    %29 = llvm.mlir.zero : !llvm.ptr
    %30 = llvm.getelementptr %29[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %31 = llvm.ptrtoint %30 : !llvm.ptr to i64
    %32 = llvm.mlir.constant(64 : index) : i64
    %33 = llvm.add %31, %32 : i64
    %34 = llvm.call @malloc(%33) : (i64) -> !llvm.ptr
    %35 = llvm.ptrtoint %34 : !llvm.ptr to i64
    %36 = llvm.mlir.constant(1 : index) : i64
    %37 = llvm.sub %32, %36 : i64
    %38 = llvm.add %35, %37 : i64
    %39 = llvm.urem %38, %32 : i64
    %40 = llvm.sub %38, %39 : i64
    %41 = llvm.inttoptr %40 : i64 to !llvm.ptr
    %42 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %43 = llvm.insertvalue %34, %42[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.insertvalue %41, %43[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.mlir.constant(0 : index) : i64
    %46 = llvm.insertvalue %45, %44[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %25, %46[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.insertvalue %26, %47[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.insertvalue %26, %48[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.insertvalue %27, %49[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%24 : i64)
  ^bb1(%51: i64):  // 2 preds: ^bb0, ^bb11
    %52 = llvm.icmp "slt" %51, %23 : i64
    llvm.cond_br %52, ^bb2, ^bb12
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%24 : i64)
  ^bb3(%53: i64):  // 2 preds: ^bb2, ^bb10
    %54 = llvm.icmp "slt" %53, %23 : i64
    llvm.cond_br %54, ^bb4, ^bb11
  ^bb4:  // pred: ^bb3
    %55 = llvm.add %51, %22 : i64
    llvm.br ^bb5(%51 : i64)
  ^bb5(%56: i64):  // 2 preds: ^bb4, ^bb9
    %57 = llvm.icmp "slt" %56, %55 : i64
    llvm.cond_br %57, ^bb6, ^bb10
  ^bb6:  // pred: ^bb5
    %58 = llvm.add %53, %22 : i64
    llvm.br ^bb7(%53 : i64)
  ^bb7(%59: i64):  // 2 preds: ^bb6, ^bb8
    %60 = llvm.icmp "slt" %59, %58 : i64
    llvm.cond_br %60, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %61 = llvm.sub %23, %59 : i64
    %62 = llvm.trunc %61 : i64 to i32
    %63 = llvm.mlir.poison : vector<8xi32>
    %64 = llvm.mlir.constant(0 : i32) : i32
    %65 = llvm.insertelement %62, %63[%64 : i32] : vector<8xi32>
    %66 = llvm.shufflevector %65, %63 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %67 = llvm.icmp "sgt" %66, %17 : vector<8xi32>
    %68 = llvm.extractvalue %50[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %69 = llvm.mlir.constant(128 : index) : i64
    %70 = llvm.mul %56, %69 : i64
    %71 = llvm.add %70, %59 : i64
    %72 = llvm.getelementptr %68[%71] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %19, %72, %67 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %73 = llvm.add %59, %20 : i64
    llvm.br ^bb7(%73 : i64)
  ^bb9:  // pred: ^bb7
    %74 = llvm.add %56, %21 : i64
    llvm.br ^bb5(%74 : i64)
  ^bb10:  // pred: ^bb5
    %75 = llvm.add %53, %22 : i64
    llvm.br ^bb3(%75 : i64)
  ^bb11:  // pred: ^bb3
    %76 = llvm.add %51, %22 : i64
    llvm.br ^bb1(%76 : i64)
  ^bb12:  // pred: ^bb1
    llvm.br ^bb13(%24 : i64)
  ^bb13(%77: i64):  // 2 preds: ^bb12, ^bb29
    %78 = llvm.icmp "slt" %77, %23 : i64
    llvm.cond_br %78, ^bb14, ^bb30
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%24 : i64)
  ^bb15(%79: i64):  // 2 preds: ^bb14, ^bb28
    %80 = llvm.icmp "slt" %79, %23 : i64
    llvm.cond_br %80, ^bb16, ^bb29
  ^bb16:  // pred: ^bb15
    llvm.br ^bb17(%24 : i64)
  ^bb17(%81: i64):  // 2 preds: ^bb16, ^bb27
    %82 = llvm.icmp "slt" %81, %23 : i64
    llvm.cond_br %82, ^bb18, ^bb28
  ^bb18:  // pred: ^bb17
    %83 = llvm.add %77, %22 : i64
    llvm.br ^bb19(%77 : i64)
  ^bb19(%84: i64):  // 2 preds: ^bb18, ^bb26
    %85 = llvm.icmp "slt" %84, %83 : i64
    llvm.cond_br %85, ^bb20, ^bb27
  ^bb20:  // pred: ^bb19
    %86 = llvm.add %79, %22 : i64
    llvm.br ^bb21(%79 : i64)
  ^bb21(%87: i64):  // 2 preds: ^bb20, ^bb25
    %88 = llvm.icmp "slt" %87, %86 : i64
    llvm.cond_br %88, ^bb22, ^bb26
  ^bb22:  // pred: ^bb21
    %89 = llvm.add %81, %18 : i64
    llvm.br ^bb23(%81 : i64)
  ^bb23(%90: i64):  // 2 preds: ^bb22, ^bb24
    %91 = llvm.icmp "slt" %90, %89 : i64
    llvm.cond_br %91, ^bb24, ^bb25
  ^bb24:  // pred: ^bb23
    %92 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %93 = llvm.mlir.constant(128 : index) : i64
    %94 = llvm.mul %84, %93 : i64
    %95 = llvm.add %94, %90 : i64
    %96 = llvm.getelementptr %92[%95] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %97 = llvm.load %96 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %98 = llvm.mlir.constant(0 : i64) : i64
    %99 = llvm.extractelement %97[%98 : i64] : vector<1xf32>
    %100 = llvm.mlir.poison : vector<8xf32>
    %101 = llvm.mlir.constant(0 : i32) : i32
    %102 = llvm.insertelement %99, %100[%101 : i32] : vector<8xf32>
    %103 = llvm.shufflevector %102, %100 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %104 = llvm.sub %23, %87 : i64
    %105 = llvm.trunc %104 : i64 to i32
    %106 = llvm.mlir.poison : vector<8xi32>
    %107 = llvm.mlir.constant(0 : i32) : i32
    %108 = llvm.insertelement %105, %106[%107 : i32] : vector<8xi32>
    %109 = llvm.shufflevector %108, %106 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %110 = llvm.icmp "sgt" %109, %17 : vector<8xi32>
    %111 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %112 = llvm.mlir.constant(128 : index) : i64
    %113 = llvm.mul %90, %112 : i64
    %114 = llvm.add %113, %87 : i64
    %115 = llvm.getelementptr %111[%114] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %116 = llvm.intr.masked.load %115, %110, %16 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %117 = llvm.sub %23, %87 : i64
    %118 = llvm.trunc %117 : i64 to i32
    %119 = llvm.mlir.poison : vector<8xi32>
    %120 = llvm.mlir.constant(0 : i32) : i32
    %121 = llvm.insertelement %118, %119[%120 : i32] : vector<8xi32>
    %122 = llvm.shufflevector %121, %119 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %123 = llvm.icmp "sgt" %122, %17 : vector<8xi32>
    %124 = llvm.extractvalue %50[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %125 = llvm.mlir.constant(128 : index) : i64
    %126 = llvm.mul %84, %125 : i64
    %127 = llvm.add %126, %87 : i64
    %128 = llvm.getelementptr %124[%127] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %129 = llvm.intr.masked.load %128, %123, %16 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %130 = llvm.fmul %103, %116 : vector<8xf32>
    %131 = llvm.fadd %129, %130 : vector<8xf32>
    %132 = llvm.sub %23, %87 : i64
    %133 = llvm.trunc %132 : i64 to i32
    %134 = llvm.mlir.poison : vector<8xi32>
    %135 = llvm.mlir.constant(0 : i32) : i32
    %136 = llvm.insertelement %133, %134[%135 : i32] : vector<8xi32>
    %137 = llvm.shufflevector %136, %134 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %138 = llvm.icmp "sgt" %137, %17 : vector<8xi32>
    %139 = llvm.extractvalue %50[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %140 = llvm.mlir.constant(128 : index) : i64
    %141 = llvm.mul %84, %140 : i64
    %142 = llvm.add %141, %87 : i64
    %143 = llvm.getelementptr %139[%142] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %131, %143, %138 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %144 = llvm.add %90, %21 : i64
    llvm.br ^bb23(%144 : i64)
  ^bb25:  // pred: ^bb23
    %145 = llvm.add %87, %20 : i64
    llvm.br ^bb21(%145 : i64)
  ^bb26:  // pred: ^bb21
    %146 = llvm.add %84, %21 : i64
    llvm.br ^bb19(%146 : i64)
  ^bb27:  // pred: ^bb19
    %147 = llvm.add %81, %18 : i64
    llvm.br ^bb17(%147 : i64)
  ^bb28:  // pred: ^bb17
    %148 = llvm.add %79, %22 : i64
    llvm.br ^bb15(%148 : i64)
  ^bb29:  // pred: ^bb15
    %149 = llvm.add %77, %22 : i64
    llvm.br ^bb13(%149 : i64)
  ^bb30:  // pred: ^bb13
    llvm.return %50 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.constant(dense<[0, 1, 2, 3, 4, 5, 6, 7]> : vector<8xi32>) : vector<8xi32>
    %1 = llvm.mlir.constant(dense<2.000000e+00> : vector<8xf32>) : vector<8xf32>
    %2 = llvm.mlir.constant(dense<1.000000e+00> : vector<8xf32>) : vector<8xf32>
    %3 = llvm.mlir.constant(8 : index) : i64
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.constant(64 : index) : i64
    %6 = llvm.mlir.constant(128 : index) : i64
    %7 = llvm.mlir.constant(0 : index) : i64
    %8 = llvm.mlir.constant(0 : i32) : i32
    %9 = llvm.mlir.constant(128 : index) : i64
    %10 = llvm.mlir.constant(128 : index) : i64
    %11 = llvm.mlir.constant(1 : index) : i64
    %12 = llvm.mlir.constant(16384 : index) : i64
    %13 = llvm.mlir.zero : !llvm.ptr
    %14 = llvm.getelementptr %13[%12] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %15 = llvm.ptrtoint %14 : !llvm.ptr to i64
    %16 = llvm.mlir.constant(64 : index) : i64
    %17 = llvm.add %15, %16 : i64
    %18 = llvm.call @malloc(%17) : (i64) -> !llvm.ptr
    %19 = llvm.ptrtoint %18 : !llvm.ptr to i64
    %20 = llvm.mlir.constant(1 : index) : i64
    %21 = llvm.sub %16, %20 : i64
    %22 = llvm.add %19, %21 : i64
    %23 = llvm.urem %22, %16 : i64
    %24 = llvm.sub %22, %23 : i64
    %25 = llvm.inttoptr %24 : i64 to !llvm.ptr
    %26 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %27 = llvm.insertvalue %18, %26[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.insertvalue %25, %27[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.mlir.constant(0 : index) : i64
    %30 = llvm.insertvalue %29, %28[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.insertvalue %9, %30[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.insertvalue %10, %31[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.insertvalue %10, %32[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.insertvalue %11, %33[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%7 : i64)
  ^bb1(%35: i64):  // 2 preds: ^bb0, ^bb11
    %36 = llvm.icmp "slt" %35, %6 : i64
    llvm.cond_br %36, ^bb2, ^bb12
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%7 : i64)
  ^bb3(%37: i64):  // 2 preds: ^bb2, ^bb10
    %38 = llvm.icmp "slt" %37, %6 : i64
    llvm.cond_br %38, ^bb4, ^bb11
  ^bb4:  // pred: ^bb3
    %39 = llvm.add %35, %5 : i64
    llvm.br ^bb5(%35 : i64)
  ^bb5(%40: i64):  // 2 preds: ^bb4, ^bb9
    %41 = llvm.icmp "slt" %40, %39 : i64
    llvm.cond_br %41, ^bb6, ^bb10
  ^bb6:  // pred: ^bb5
    %42 = llvm.add %37, %5 : i64
    llvm.br ^bb7(%37 : i64)
  ^bb7(%43: i64):  // 2 preds: ^bb6, ^bb8
    %44 = llvm.icmp "slt" %43, %42 : i64
    llvm.cond_br %44, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %45 = llvm.sub %6, %43 : i64
    %46 = llvm.trunc %45 : i64 to i32
    %47 = llvm.mlir.poison : vector<8xi32>
    %48 = llvm.mlir.constant(0 : i32) : i32
    %49 = llvm.insertelement %46, %47[%48 : i32] : vector<8xi32>
    %50 = llvm.shufflevector %49, %47 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %51 = llvm.icmp "sgt" %50, %0 : vector<8xi32>
    %52 = llvm.extractvalue %34[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.mlir.constant(128 : index) : i64
    %54 = llvm.mul %40, %53 : i64
    %55 = llvm.add %54, %43 : i64
    %56 = llvm.getelementptr %52[%55] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %2, %56, %51 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %57 = llvm.add %43, %3 : i64
    llvm.br ^bb7(%57 : i64)
  ^bb9:  // pred: ^bb7
    %58 = llvm.add %40, %4 : i64
    llvm.br ^bb5(%58 : i64)
  ^bb10:  // pred: ^bb5
    %59 = llvm.add %37, %5 : i64
    llvm.br ^bb3(%59 : i64)
  ^bb11:  // pred: ^bb3
    %60 = llvm.add %35, %5 : i64
    llvm.br ^bb1(%60 : i64)
  ^bb12:  // pred: ^bb1
    %61 = llvm.mlir.constant(128 : index) : i64
    %62 = llvm.mlir.constant(128 : index) : i64
    %63 = llvm.mlir.constant(1 : index) : i64
    %64 = llvm.mlir.constant(16384 : index) : i64
    %65 = llvm.mlir.zero : !llvm.ptr
    %66 = llvm.getelementptr %65[%64] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %67 = llvm.ptrtoint %66 : !llvm.ptr to i64
    %68 = llvm.mlir.constant(64 : index) : i64
    %69 = llvm.add %67, %68 : i64
    %70 = llvm.call @malloc(%69) : (i64) -> !llvm.ptr
    %71 = llvm.ptrtoint %70 : !llvm.ptr to i64
    %72 = llvm.mlir.constant(1 : index) : i64
    %73 = llvm.sub %68, %72 : i64
    %74 = llvm.add %71, %73 : i64
    %75 = llvm.urem %74, %68 : i64
    %76 = llvm.sub %74, %75 : i64
    %77 = llvm.inttoptr %76 : i64 to !llvm.ptr
    %78 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %79 = llvm.insertvalue %70, %78[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %80 = llvm.insertvalue %77, %79[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %81 = llvm.mlir.constant(0 : index) : i64
    %82 = llvm.insertvalue %81, %80[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %83 = llvm.insertvalue %61, %82[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %84 = llvm.insertvalue %62, %83[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %85 = llvm.insertvalue %62, %84[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %86 = llvm.insertvalue %63, %85[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb13(%7 : i64)
  ^bb13(%87: i64):  // 2 preds: ^bb12, ^bb23
    %88 = llvm.icmp "slt" %87, %6 : i64
    llvm.cond_br %88, ^bb14, ^bb24
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%7 : i64)
  ^bb15(%89: i64):  // 2 preds: ^bb14, ^bb22
    %90 = llvm.icmp "slt" %89, %6 : i64
    llvm.cond_br %90, ^bb16, ^bb23
  ^bb16:  // pred: ^bb15
    %91 = llvm.add %87, %5 : i64
    llvm.br ^bb17(%87 : i64)
  ^bb17(%92: i64):  // 2 preds: ^bb16, ^bb21
    %93 = llvm.icmp "slt" %92, %91 : i64
    llvm.cond_br %93, ^bb18, ^bb22
  ^bb18:  // pred: ^bb17
    %94 = llvm.add %89, %5 : i64
    llvm.br ^bb19(%89 : i64)
  ^bb19(%95: i64):  // 2 preds: ^bb18, ^bb20
    %96 = llvm.icmp "slt" %95, %94 : i64
    llvm.cond_br %96, ^bb20, ^bb21
  ^bb20:  // pred: ^bb19
    %97 = llvm.sub %6, %95 : i64
    %98 = llvm.trunc %97 : i64 to i32
    %99 = llvm.mlir.poison : vector<8xi32>
    %100 = llvm.mlir.constant(0 : i32) : i32
    %101 = llvm.insertelement %98, %99[%100 : i32] : vector<8xi32>
    %102 = llvm.shufflevector %101, %99 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %103 = llvm.icmp "sgt" %102, %0 : vector<8xi32>
    %104 = llvm.extractvalue %86[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.mlir.constant(128 : index) : i64
    %106 = llvm.mul %92, %105 : i64
    %107 = llvm.add %106, %95 : i64
    %108 = llvm.getelementptr %104[%107] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %1, %108, %103 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %109 = llvm.add %95, %3 : i64
    llvm.br ^bb19(%109 : i64)
  ^bb21:  // pred: ^bb19
    %110 = llvm.add %92, %4 : i64
    llvm.br ^bb17(%110 : i64)
  ^bb22:  // pred: ^bb17
    %111 = llvm.add %89, %5 : i64
    llvm.br ^bb15(%111 : i64)
  ^bb23:  // pred: ^bb15
    %112 = llvm.add %87, %5 : i64
    llvm.br ^bb13(%112 : i64)
  ^bb24:  // pred: ^bb13
    %113 = llvm.extractvalue %34[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %114 = llvm.extractvalue %34[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %115 = llvm.extractvalue %34[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %116 = llvm.extractvalue %34[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %117 = llvm.extractvalue %34[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %118 = llvm.extractvalue %34[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %119 = llvm.extractvalue %34[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %120 = llvm.extractvalue %86[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %121 = llvm.extractvalue %86[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.extractvalue %86[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %123 = llvm.extractvalue %86[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.extractvalue %86[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %125 = llvm.extractvalue %86[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.extractvalue %86[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %127 = llvm.call @matmul(%113, %114, %115, %116, %117, %118, %119, %120, %121, %122, %123, %124, %125, %126) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.return %8 : i32
  }
}

