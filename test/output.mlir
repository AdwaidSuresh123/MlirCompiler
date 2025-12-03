module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.mlir.global private constant @__constant_4096x4096xf32_0(dense<2.000000e+00> : tensor<4096x4096xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<4096 x array<4096 x f32>>
  llvm.mlir.global private constant @__constant_4096x4096xf32(dense<1.000000e+00> : tensor<4096x4096xf32>) {addr_space = 0 : i32, alignment = 64 : i64} : !llvm.array<4096 x array<4096 x f32>>
  llvm.func @get_time() -> i64 attributes {sym_visibility = "private"}
  llvm.func @print_gflops(i64, i64, i64, i64) attributes {sym_visibility = "private"}
  llvm.func @matmul_4096(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> {
    %0 = llvm.mlir.poison : vector<8xi32>
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.poison : vector<8xf32>
    %3 = llvm.mlir.constant(0 : i64) : i64
    %4 = llvm.mlir.constant(64 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.mlir.constant(4096 : i64) : i64
    %7 = llvm.mlir.constant(0 : index) : i64
    %8 = llvm.mlir.constant(4096 : index) : i64
    %9 = llvm.mlir.constant(32 : index) : i64
    %10 = llvm.mlir.constant(8 : index) : i64
    %11 = llvm.mlir.constant(1 : index) : i64
    %12 = llvm.mlir.constant(2 : index) : i64
    %13 = llvm.mlir.constant(3 : index) : i64
    %14 = llvm.mlir.constant(4 : index) : i64
    %15 = llvm.mlir.constant(5 : index) : i64
    %16 = llvm.mlir.constant(6 : index) : i64
    %17 = llvm.mlir.constant(7 : index) : i64
    %18 = llvm.mlir.constant(dense<0.000000e+00> : vector<8x1xf32>) : !llvm.array<8 x vector<1xf32>>
    %19 = llvm.mlir.constant(dense<[0, 1, 2, 3, 4, 5, 6, 7]> : vector<8xi32>) : vector<8xi32>
    %20 = llvm.mlir.undef : vector<8xf32>
    %21 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %22 = llvm.getelementptr %5[16777216] : (!llvm.ptr) -> !llvm.ptr, f32
    %23 = llvm.ptrtoint %22 : !llvm.ptr to i64
    %24 = llvm.add %23, %4 : i64
    %25 = llvm.call @malloc(%24) : (i64) -> !llvm.ptr
    %26 = llvm.ptrtoint %25 : !llvm.ptr to i64
    %27 = llvm.sub %4, %11 : i64
    %28 = llvm.add %26, %27 : i64
    %29 = llvm.urem %28, %4 : i64
    %30 = llvm.sub %28, %29 : i64
    %31 = llvm.inttoptr %30 : i64 to !llvm.ptr
    %32 = llvm.insertvalue %25, %21[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.insertvalue %31, %32[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.insertvalue %7, %33[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.insertvalue %8, %34[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.insertvalue %8, %35[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.insertvalue %8, %36[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.insertvalue %11, %37[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%7 : i64)
  ^bb1(%39: i64):  // 2 preds: ^bb0, ^bb50
    %40 = llvm.icmp "slt" %39, %8 : i64
    llvm.cond_br %40, ^bb2(%7 : i64), ^bb51
  ^bb2(%41: i64):  // 2 preds: ^bb1, ^bb49
    %42 = llvm.icmp "slt" %41, %8 : i64
    llvm.cond_br %42, ^bb3, ^bb50
  ^bb3:  // pred: ^bb2
    %43 = llvm.add %39, %9 : i64
    llvm.br ^bb4(%39 : i64)
  ^bb4(%44: i64):  // 2 preds: ^bb3, ^bb48
    %45 = llvm.icmp "slt" %44, %43 : i64
    llvm.cond_br %45, ^bb5, ^bb49
  ^bb5:  // pred: ^bb4
    %46 = llvm.add %41, %9 : i64
    llvm.br ^bb6(%41 : i64)
  ^bb6(%47: i64):  // 2 preds: ^bb5, ^bb47
    %48 = llvm.icmp "slt" %47, %46 : i64
    llvm.cond_br %48, ^bb7, ^bb48
  ^bb7:  // pred: ^bb6
    %49 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %50 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %51 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %52 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %53 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %54 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %55 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    %56 = llvm.alloca %11 x !llvm.array<8 x vector<1xf32>> : (i64) -> !llvm.ptr
    llvm.store %18, %49 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb8(%7 : i64)
  ^bb8(%57: i64):  // 2 preds: ^bb7, ^bb11
    %58 = llvm.icmp "slt" %57, %10 : i64
    llvm.cond_br %58, ^bb9, ^bb12
  ^bb9:  // pred: ^bb8
    %59 = llvm.add %44, %57 : i64
    %60 = llvm.icmp "slt" %59, %8 : i64
    llvm.cond_br %60, ^bb10, ^bb11
  ^bb10:  // pred: ^bb9
    %61 = llvm.add %44, %57 : i64
    %62 = llvm.getelementptr inbounds|nuw %49[%57] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %63 = llvm.load %62 : !llvm.ptr -> vector<1xf32>
    %64 = llvm.mul %61, %8 : i64
    %65 = llvm.add %64, %47 : i64
    %66 = llvm.getelementptr %31[%65] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %63, %66 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb11
  ^bb11:  // 2 preds: ^bb9, ^bb10
    %67 = llvm.add %57, %11 : i64
    llvm.br ^bb8(%67 : i64)
  ^bb12:  // pred: ^bb8
    %68 = llvm.add %47, %11 : i64
    llvm.store %18, %50 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb13(%7 : i64)
  ^bb13(%69: i64):  // 2 preds: ^bb12, ^bb16
    %70 = llvm.icmp "slt" %69, %10 : i64
    llvm.cond_br %70, ^bb14, ^bb17
  ^bb14:  // pred: ^bb13
    %71 = llvm.add %44, %69 : i64
    %72 = llvm.icmp "slt" %71, %8 : i64
    llvm.cond_br %72, ^bb15, ^bb16
  ^bb15:  // pred: ^bb14
    %73 = llvm.add %44, %69 : i64
    %74 = llvm.getelementptr inbounds|nuw %50[%69] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %75 = llvm.load %74 : !llvm.ptr -> vector<1xf32>
    %76 = llvm.mul %73, %8 : i64
    %77 = llvm.add %76, %68 : i64
    %78 = llvm.getelementptr %31[%77] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %75, %78 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb16
  ^bb16:  // 2 preds: ^bb14, ^bb15
    %79 = llvm.add %69, %11 : i64
    llvm.br ^bb13(%79 : i64)
  ^bb17:  // pred: ^bb13
    %80 = llvm.add %47, %12 : i64
    llvm.store %18, %51 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb18(%7 : i64)
  ^bb18(%81: i64):  // 2 preds: ^bb17, ^bb21
    %82 = llvm.icmp "slt" %81, %10 : i64
    llvm.cond_br %82, ^bb19, ^bb22
  ^bb19:  // pred: ^bb18
    %83 = llvm.add %44, %81 : i64
    %84 = llvm.icmp "slt" %83, %8 : i64
    llvm.cond_br %84, ^bb20, ^bb21
  ^bb20:  // pred: ^bb19
    %85 = llvm.add %44, %81 : i64
    %86 = llvm.getelementptr inbounds|nuw %51[%81] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %87 = llvm.load %86 : !llvm.ptr -> vector<1xf32>
    %88 = llvm.mul %85, %8 : i64
    %89 = llvm.add %88, %80 : i64
    %90 = llvm.getelementptr %31[%89] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %87, %90 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb21
  ^bb21:  // 2 preds: ^bb19, ^bb20
    %91 = llvm.add %81, %11 : i64
    llvm.br ^bb18(%91 : i64)
  ^bb22:  // pred: ^bb18
    %92 = llvm.add %47, %13 : i64
    llvm.store %18, %52 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb23(%7 : i64)
  ^bb23(%93: i64):  // 2 preds: ^bb22, ^bb26
    %94 = llvm.icmp "slt" %93, %10 : i64
    llvm.cond_br %94, ^bb24, ^bb27
  ^bb24:  // pred: ^bb23
    %95 = llvm.add %44, %93 : i64
    %96 = llvm.icmp "slt" %95, %8 : i64
    llvm.cond_br %96, ^bb25, ^bb26
  ^bb25:  // pred: ^bb24
    %97 = llvm.add %44, %93 : i64
    %98 = llvm.getelementptr inbounds|nuw %52[%93] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %99 = llvm.load %98 : !llvm.ptr -> vector<1xf32>
    %100 = llvm.mul %97, %8 : i64
    %101 = llvm.add %100, %92 : i64
    %102 = llvm.getelementptr %31[%101] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %99, %102 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb26
  ^bb26:  // 2 preds: ^bb24, ^bb25
    %103 = llvm.add %93, %11 : i64
    llvm.br ^bb23(%103 : i64)
  ^bb27:  // pred: ^bb23
    %104 = llvm.add %47, %14 : i64
    llvm.store %18, %53 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb28(%7 : i64)
  ^bb28(%105: i64):  // 2 preds: ^bb27, ^bb31
    %106 = llvm.icmp "slt" %105, %10 : i64
    llvm.cond_br %106, ^bb29, ^bb32
  ^bb29:  // pred: ^bb28
    %107 = llvm.add %44, %105 : i64
    %108 = llvm.icmp "slt" %107, %8 : i64
    llvm.cond_br %108, ^bb30, ^bb31
  ^bb30:  // pred: ^bb29
    %109 = llvm.add %44, %105 : i64
    %110 = llvm.getelementptr inbounds|nuw %53[%105] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %111 = llvm.load %110 : !llvm.ptr -> vector<1xf32>
    %112 = llvm.mul %109, %8 : i64
    %113 = llvm.add %112, %104 : i64
    %114 = llvm.getelementptr %31[%113] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %111, %114 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb31
  ^bb31:  // 2 preds: ^bb29, ^bb30
    %115 = llvm.add %105, %11 : i64
    llvm.br ^bb28(%115 : i64)
  ^bb32:  // pred: ^bb28
    %116 = llvm.add %47, %15 : i64
    llvm.store %18, %54 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb33(%7 : i64)
  ^bb33(%117: i64):  // 2 preds: ^bb32, ^bb36
    %118 = llvm.icmp "slt" %117, %10 : i64
    llvm.cond_br %118, ^bb34, ^bb37
  ^bb34:  // pred: ^bb33
    %119 = llvm.add %44, %117 : i64
    %120 = llvm.icmp "slt" %119, %8 : i64
    llvm.cond_br %120, ^bb35, ^bb36
  ^bb35:  // pred: ^bb34
    %121 = llvm.add %44, %117 : i64
    %122 = llvm.getelementptr inbounds|nuw %54[%117] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %123 = llvm.load %122 : !llvm.ptr -> vector<1xf32>
    %124 = llvm.mul %121, %8 : i64
    %125 = llvm.add %124, %116 : i64
    %126 = llvm.getelementptr %31[%125] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %123, %126 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb36
  ^bb36:  // 2 preds: ^bb34, ^bb35
    %127 = llvm.add %117, %11 : i64
    llvm.br ^bb33(%127 : i64)
  ^bb37:  // pred: ^bb33
    %128 = llvm.add %47, %16 : i64
    llvm.store %18, %55 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb38(%7 : i64)
  ^bb38(%129: i64):  // 2 preds: ^bb37, ^bb41
    %130 = llvm.icmp "slt" %129, %10 : i64
    llvm.cond_br %130, ^bb39, ^bb42
  ^bb39:  // pred: ^bb38
    %131 = llvm.add %44, %129 : i64
    %132 = llvm.icmp "slt" %131, %8 : i64
    llvm.cond_br %132, ^bb40, ^bb41
  ^bb40:  // pred: ^bb39
    %133 = llvm.add %44, %129 : i64
    %134 = llvm.getelementptr inbounds|nuw %55[%129] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %135 = llvm.load %134 : !llvm.ptr -> vector<1xf32>
    %136 = llvm.mul %133, %8 : i64
    %137 = llvm.add %136, %128 : i64
    %138 = llvm.getelementptr %31[%137] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %135, %138 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb41
  ^bb41:  // 2 preds: ^bb39, ^bb40
    %139 = llvm.add %129, %11 : i64
    llvm.br ^bb38(%139 : i64)
  ^bb42:  // pred: ^bb38
    %140 = llvm.add %47, %17 : i64
    llvm.store %18, %56 : !llvm.array<8 x vector<1xf32>>, !llvm.ptr
    llvm.br ^bb43(%7 : i64)
  ^bb43(%141: i64):  // 2 preds: ^bb42, ^bb46
    %142 = llvm.icmp "slt" %141, %10 : i64
    llvm.cond_br %142, ^bb44, ^bb47
  ^bb44:  // pred: ^bb43
    %143 = llvm.add %44, %141 : i64
    %144 = llvm.icmp "slt" %143, %8 : i64
    llvm.cond_br %144, ^bb45, ^bb46
  ^bb45:  // pred: ^bb44
    %145 = llvm.add %44, %141 : i64
    %146 = llvm.getelementptr inbounds|nuw %56[%141] : (!llvm.ptr, i64) -> !llvm.ptr, vector<1xf32>
    %147 = llvm.load %146 : !llvm.ptr -> vector<1xf32>
    %148 = llvm.mul %145, %8 : i64
    %149 = llvm.add %148, %140 : i64
    %150 = llvm.getelementptr %31[%149] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %147, %150 {alignment = 4 : i64} : vector<1xf32>, !llvm.ptr
    llvm.br ^bb46
  ^bb46:  // 2 preds: ^bb44, ^bb45
    %151 = llvm.add %141, %11 : i64
    llvm.br ^bb43(%151 : i64)
  ^bb47:  // pred: ^bb43
    %152 = llvm.add %47, %10 : i64
    llvm.br ^bb6(%152 : i64)
  ^bb48:  // pred: ^bb6
    %153 = llvm.add %44, %10 : i64
    llvm.br ^bb4(%153 : i64)
  ^bb49:  // pred: ^bb4
    %154 = llvm.add %41, %9 : i64
    llvm.br ^bb2(%154 : i64)
  ^bb50:  // pred: ^bb2
    %155 = llvm.add %39, %9 : i64
    llvm.br ^bb1(%155 : i64)
  ^bb51:  // pred: ^bb1
    %156 = llvm.call @get_time() : () -> i64
    llvm.br ^bb52(%7 : i64)
  ^bb52(%157: i64):  // 2 preds: ^bb51, ^bb63
    %158 = llvm.icmp "slt" %157, %8 : i64
    llvm.cond_br %158, ^bb53(%7 : i64), ^bb64
  ^bb53(%159: i64):  // 2 preds: ^bb52, ^bb62
    %160 = llvm.icmp "slt" %159, %8 : i64
    llvm.cond_br %160, ^bb54(%7 : i64), ^bb63
  ^bb54(%161: i64):  // 2 preds: ^bb53, ^bb61
    %162 = llvm.icmp "slt" %161, %8 : i64
    llvm.cond_br %162, ^bb55, ^bb62
  ^bb55:  // pred: ^bb54
    %163 = llvm.add %157, %9 : i64
    llvm.br ^bb56(%157 : i64)
  ^bb56(%164: i64):  // 2 preds: ^bb55, ^bb60
    %165 = llvm.icmp "slt" %164, %163 : i64
    llvm.cond_br %165, ^bb57, ^bb61
  ^bb57:  // pred: ^bb56
    %166 = llvm.add %159, %9 : i64
    llvm.br ^bb58(%159 : i64)
  ^bb58(%167: i64):  // 2 preds: ^bb57, ^bb59
    %168 = llvm.icmp "slt" %167, %166 : i64
    llvm.cond_br %168, ^bb59, ^bb60
  ^bb59:  // pred: ^bb58
    %169 = llvm.mul %164, %8 : i64
    %170 = llvm.add %169, %161 : i64
    %171 = llvm.getelementptr %arg1[%170] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %172 = llvm.load %171 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %173 = llvm.extractelement %172[%3 : i64] : vector<1xf32>
    %174 = llvm.insertelement %173, %2[%1 : i32] : vector<8xf32>
    %175 = llvm.shufflevector %174, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %176 = llvm.sub %8, %167 : i64
    %177 = llvm.trunc %176 : i64 to i32
    %178 = llvm.insertelement %177, %0[%1 : i32] : vector<8xi32>
    %179 = llvm.shufflevector %178, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %180 = llvm.icmp "sgt" %179, %19 : vector<8xi32>
    %181 = llvm.mul %161, %8 : i64
    %182 = llvm.add %181, %167 : i64
    %183 = llvm.getelementptr %arg8[%182] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %184 = llvm.intr.masked.load %183, %180, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %185 = llvm.sub %8, %167 : i64
    %186 = llvm.trunc %185 : i64 to i32
    %187 = llvm.insertelement %186, %0[%1 : i32] : vector<8xi32>
    %188 = llvm.shufflevector %187, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %189 = llvm.icmp "sgt" %188, %19 : vector<8xi32>
    %190 = llvm.mul %164, %8 : i64
    %191 = llvm.add %190, %167 : i64
    %192 = llvm.getelementptr %31[%191] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %193 = llvm.intr.masked.load %192, %189, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %194 = llvm.fmul %175, %184 : vector<8xf32>
    %195 = llvm.fadd %193, %194 : vector<8xf32>
    %196 = llvm.sub %8, %167 : i64
    %197 = llvm.trunc %196 : i64 to i32
    %198 = llvm.insertelement %197, %0[%1 : i32] : vector<8xi32>
    %199 = llvm.shufflevector %198, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %200 = llvm.icmp "sgt" %199, %19 : vector<8xi32>
    %201 = llvm.mul %164, %8 : i64
    %202 = llvm.add %201, %167 : i64
    %203 = llvm.getelementptr %31[%202] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %195, %203, %200 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %204 = llvm.add %161, %11 : i64
    %205 = llvm.mul %164, %8 : i64
    %206 = llvm.add %205, %204 : i64
    %207 = llvm.getelementptr %arg1[%206] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %208 = llvm.load %207 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %209 = llvm.extractelement %208[%3 : i64] : vector<1xf32>
    %210 = llvm.insertelement %209, %2[%1 : i32] : vector<8xf32>
    %211 = llvm.shufflevector %210, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %212 = llvm.add %161, %11 : i64
    %213 = llvm.sub %8, %167 : i64
    %214 = llvm.trunc %213 : i64 to i32
    %215 = llvm.insertelement %214, %0[%1 : i32] : vector<8xi32>
    %216 = llvm.shufflevector %215, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %217 = llvm.icmp "sgt" %216, %19 : vector<8xi32>
    %218 = llvm.mul %212, %8 : i64
    %219 = llvm.add %218, %167 : i64
    %220 = llvm.getelementptr %arg8[%219] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %221 = llvm.intr.masked.load %220, %217, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %222 = llvm.sub %8, %167 : i64
    %223 = llvm.trunc %222 : i64 to i32
    %224 = llvm.insertelement %223, %0[%1 : i32] : vector<8xi32>
    %225 = llvm.shufflevector %224, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %226 = llvm.icmp "sgt" %225, %19 : vector<8xi32>
    %227 = llvm.mul %164, %8 : i64
    %228 = llvm.add %227, %167 : i64
    %229 = llvm.getelementptr %31[%228] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %230 = llvm.intr.masked.load %229, %226, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %231 = llvm.fmul %211, %221 : vector<8xf32>
    %232 = llvm.fadd %230, %231 : vector<8xf32>
    %233 = llvm.sub %8, %167 : i64
    %234 = llvm.trunc %233 : i64 to i32
    %235 = llvm.insertelement %234, %0[%1 : i32] : vector<8xi32>
    %236 = llvm.shufflevector %235, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %237 = llvm.icmp "sgt" %236, %19 : vector<8xi32>
    %238 = llvm.mul %164, %8 : i64
    %239 = llvm.add %238, %167 : i64
    %240 = llvm.getelementptr %31[%239] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %232, %240, %237 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %241 = llvm.add %161, %12 : i64
    %242 = llvm.mul %164, %8 : i64
    %243 = llvm.add %242, %241 : i64
    %244 = llvm.getelementptr %arg1[%243] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %245 = llvm.load %244 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %246 = llvm.extractelement %245[%3 : i64] : vector<1xf32>
    %247 = llvm.insertelement %246, %2[%1 : i32] : vector<8xf32>
    %248 = llvm.shufflevector %247, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %249 = llvm.add %161, %12 : i64
    %250 = llvm.sub %8, %167 : i64
    %251 = llvm.trunc %250 : i64 to i32
    %252 = llvm.insertelement %251, %0[%1 : i32] : vector<8xi32>
    %253 = llvm.shufflevector %252, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %254 = llvm.icmp "sgt" %253, %19 : vector<8xi32>
    %255 = llvm.mul %249, %8 : i64
    %256 = llvm.add %255, %167 : i64
    %257 = llvm.getelementptr %arg8[%256] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %258 = llvm.intr.masked.load %257, %254, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %259 = llvm.sub %8, %167 : i64
    %260 = llvm.trunc %259 : i64 to i32
    %261 = llvm.insertelement %260, %0[%1 : i32] : vector<8xi32>
    %262 = llvm.shufflevector %261, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %263 = llvm.icmp "sgt" %262, %19 : vector<8xi32>
    %264 = llvm.mul %164, %8 : i64
    %265 = llvm.add %264, %167 : i64
    %266 = llvm.getelementptr %31[%265] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %267 = llvm.intr.masked.load %266, %263, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %268 = llvm.fmul %248, %258 : vector<8xf32>
    %269 = llvm.fadd %267, %268 : vector<8xf32>
    %270 = llvm.sub %8, %167 : i64
    %271 = llvm.trunc %270 : i64 to i32
    %272 = llvm.insertelement %271, %0[%1 : i32] : vector<8xi32>
    %273 = llvm.shufflevector %272, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %274 = llvm.icmp "sgt" %273, %19 : vector<8xi32>
    %275 = llvm.mul %164, %8 : i64
    %276 = llvm.add %275, %167 : i64
    %277 = llvm.getelementptr %31[%276] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %269, %277, %274 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %278 = llvm.add %161, %13 : i64
    %279 = llvm.mul %164, %8 : i64
    %280 = llvm.add %279, %278 : i64
    %281 = llvm.getelementptr %arg1[%280] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %282 = llvm.load %281 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %283 = llvm.extractelement %282[%3 : i64] : vector<1xf32>
    %284 = llvm.insertelement %283, %2[%1 : i32] : vector<8xf32>
    %285 = llvm.shufflevector %284, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %286 = llvm.add %161, %13 : i64
    %287 = llvm.sub %8, %167 : i64
    %288 = llvm.trunc %287 : i64 to i32
    %289 = llvm.insertelement %288, %0[%1 : i32] : vector<8xi32>
    %290 = llvm.shufflevector %289, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %291 = llvm.icmp "sgt" %290, %19 : vector<8xi32>
    %292 = llvm.mul %286, %8 : i64
    %293 = llvm.add %292, %167 : i64
    %294 = llvm.getelementptr %arg8[%293] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %295 = llvm.intr.masked.load %294, %291, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %296 = llvm.sub %8, %167 : i64
    %297 = llvm.trunc %296 : i64 to i32
    %298 = llvm.insertelement %297, %0[%1 : i32] : vector<8xi32>
    %299 = llvm.shufflevector %298, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %300 = llvm.icmp "sgt" %299, %19 : vector<8xi32>
    %301 = llvm.mul %164, %8 : i64
    %302 = llvm.add %301, %167 : i64
    %303 = llvm.getelementptr %31[%302] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %304 = llvm.intr.masked.load %303, %300, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %305 = llvm.fmul %285, %295 : vector<8xf32>
    %306 = llvm.fadd %304, %305 : vector<8xf32>
    %307 = llvm.sub %8, %167 : i64
    %308 = llvm.trunc %307 : i64 to i32
    %309 = llvm.insertelement %308, %0[%1 : i32] : vector<8xi32>
    %310 = llvm.shufflevector %309, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %311 = llvm.icmp "sgt" %310, %19 : vector<8xi32>
    %312 = llvm.mul %164, %8 : i64
    %313 = llvm.add %312, %167 : i64
    %314 = llvm.getelementptr %31[%313] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %306, %314, %311 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %315 = llvm.add %161, %14 : i64
    %316 = llvm.mul %164, %8 : i64
    %317 = llvm.add %316, %315 : i64
    %318 = llvm.getelementptr %arg1[%317] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %319 = llvm.load %318 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %320 = llvm.extractelement %319[%3 : i64] : vector<1xf32>
    %321 = llvm.insertelement %320, %2[%1 : i32] : vector<8xf32>
    %322 = llvm.shufflevector %321, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %323 = llvm.add %161, %14 : i64
    %324 = llvm.sub %8, %167 : i64
    %325 = llvm.trunc %324 : i64 to i32
    %326 = llvm.insertelement %325, %0[%1 : i32] : vector<8xi32>
    %327 = llvm.shufflevector %326, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %328 = llvm.icmp "sgt" %327, %19 : vector<8xi32>
    %329 = llvm.mul %323, %8 : i64
    %330 = llvm.add %329, %167 : i64
    %331 = llvm.getelementptr %arg8[%330] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %332 = llvm.intr.masked.load %331, %328, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %333 = llvm.sub %8, %167 : i64
    %334 = llvm.trunc %333 : i64 to i32
    %335 = llvm.insertelement %334, %0[%1 : i32] : vector<8xi32>
    %336 = llvm.shufflevector %335, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %337 = llvm.icmp "sgt" %336, %19 : vector<8xi32>
    %338 = llvm.mul %164, %8 : i64
    %339 = llvm.add %338, %167 : i64
    %340 = llvm.getelementptr %31[%339] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %341 = llvm.intr.masked.load %340, %337, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %342 = llvm.fmul %322, %332 : vector<8xf32>
    %343 = llvm.fadd %341, %342 : vector<8xf32>
    %344 = llvm.sub %8, %167 : i64
    %345 = llvm.trunc %344 : i64 to i32
    %346 = llvm.insertelement %345, %0[%1 : i32] : vector<8xi32>
    %347 = llvm.shufflevector %346, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %348 = llvm.icmp "sgt" %347, %19 : vector<8xi32>
    %349 = llvm.mul %164, %8 : i64
    %350 = llvm.add %349, %167 : i64
    %351 = llvm.getelementptr %31[%350] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %343, %351, %348 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %352 = llvm.add %161, %15 : i64
    %353 = llvm.mul %164, %8 : i64
    %354 = llvm.add %353, %352 : i64
    %355 = llvm.getelementptr %arg1[%354] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %356 = llvm.load %355 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %357 = llvm.extractelement %356[%3 : i64] : vector<1xf32>
    %358 = llvm.insertelement %357, %2[%1 : i32] : vector<8xf32>
    %359 = llvm.shufflevector %358, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %360 = llvm.add %161, %15 : i64
    %361 = llvm.sub %8, %167 : i64
    %362 = llvm.trunc %361 : i64 to i32
    %363 = llvm.insertelement %362, %0[%1 : i32] : vector<8xi32>
    %364 = llvm.shufflevector %363, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %365 = llvm.icmp "sgt" %364, %19 : vector<8xi32>
    %366 = llvm.mul %360, %8 : i64
    %367 = llvm.add %366, %167 : i64
    %368 = llvm.getelementptr %arg8[%367] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %369 = llvm.intr.masked.load %368, %365, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %370 = llvm.sub %8, %167 : i64
    %371 = llvm.trunc %370 : i64 to i32
    %372 = llvm.insertelement %371, %0[%1 : i32] : vector<8xi32>
    %373 = llvm.shufflevector %372, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %374 = llvm.icmp "sgt" %373, %19 : vector<8xi32>
    %375 = llvm.mul %164, %8 : i64
    %376 = llvm.add %375, %167 : i64
    %377 = llvm.getelementptr %31[%376] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %378 = llvm.intr.masked.load %377, %374, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %379 = llvm.fmul %359, %369 : vector<8xf32>
    %380 = llvm.fadd %378, %379 : vector<8xf32>
    %381 = llvm.sub %8, %167 : i64
    %382 = llvm.trunc %381 : i64 to i32
    %383 = llvm.insertelement %382, %0[%1 : i32] : vector<8xi32>
    %384 = llvm.shufflevector %383, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %385 = llvm.icmp "sgt" %384, %19 : vector<8xi32>
    %386 = llvm.mul %164, %8 : i64
    %387 = llvm.add %386, %167 : i64
    %388 = llvm.getelementptr %31[%387] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %380, %388, %385 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %389 = llvm.add %161, %16 : i64
    %390 = llvm.mul %164, %8 : i64
    %391 = llvm.add %390, %389 : i64
    %392 = llvm.getelementptr %arg1[%391] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %393 = llvm.load %392 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %394 = llvm.extractelement %393[%3 : i64] : vector<1xf32>
    %395 = llvm.insertelement %394, %2[%1 : i32] : vector<8xf32>
    %396 = llvm.shufflevector %395, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %397 = llvm.add %161, %16 : i64
    %398 = llvm.sub %8, %167 : i64
    %399 = llvm.trunc %398 : i64 to i32
    %400 = llvm.insertelement %399, %0[%1 : i32] : vector<8xi32>
    %401 = llvm.shufflevector %400, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %402 = llvm.icmp "sgt" %401, %19 : vector<8xi32>
    %403 = llvm.mul %397, %8 : i64
    %404 = llvm.add %403, %167 : i64
    %405 = llvm.getelementptr %arg8[%404] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %406 = llvm.intr.masked.load %405, %402, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %407 = llvm.sub %8, %167 : i64
    %408 = llvm.trunc %407 : i64 to i32
    %409 = llvm.insertelement %408, %0[%1 : i32] : vector<8xi32>
    %410 = llvm.shufflevector %409, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %411 = llvm.icmp "sgt" %410, %19 : vector<8xi32>
    %412 = llvm.mul %164, %8 : i64
    %413 = llvm.add %412, %167 : i64
    %414 = llvm.getelementptr %31[%413] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %415 = llvm.intr.masked.load %414, %411, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %416 = llvm.fmul %396, %406 : vector<8xf32>
    %417 = llvm.fadd %415, %416 : vector<8xf32>
    %418 = llvm.sub %8, %167 : i64
    %419 = llvm.trunc %418 : i64 to i32
    %420 = llvm.insertelement %419, %0[%1 : i32] : vector<8xi32>
    %421 = llvm.shufflevector %420, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %422 = llvm.icmp "sgt" %421, %19 : vector<8xi32>
    %423 = llvm.mul %164, %8 : i64
    %424 = llvm.add %423, %167 : i64
    %425 = llvm.getelementptr %31[%424] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %417, %425, %422 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %426 = llvm.add %161, %17 : i64
    %427 = llvm.mul %164, %8 : i64
    %428 = llvm.add %427, %426 : i64
    %429 = llvm.getelementptr %arg1[%428] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %430 = llvm.load %429 {alignment = 4 : i64} : !llvm.ptr -> vector<1xf32>
    %431 = llvm.extractelement %430[%3 : i64] : vector<1xf32>
    %432 = llvm.insertelement %431, %2[%1 : i32] : vector<8xf32>
    %433 = llvm.shufflevector %432, %2 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xf32> 
    %434 = llvm.add %161, %17 : i64
    %435 = llvm.sub %8, %167 : i64
    %436 = llvm.trunc %435 : i64 to i32
    %437 = llvm.insertelement %436, %0[%1 : i32] : vector<8xi32>
    %438 = llvm.shufflevector %437, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %439 = llvm.icmp "sgt" %438, %19 : vector<8xi32>
    %440 = llvm.mul %434, %8 : i64
    %441 = llvm.add %440, %167 : i64
    %442 = llvm.getelementptr %arg8[%441] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %443 = llvm.intr.masked.load %442, %439, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %444 = llvm.sub %8, %167 : i64
    %445 = llvm.trunc %444 : i64 to i32
    %446 = llvm.insertelement %445, %0[%1 : i32] : vector<8xi32>
    %447 = llvm.shufflevector %446, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %448 = llvm.icmp "sgt" %447, %19 : vector<8xi32>
    %449 = llvm.mul %164, %8 : i64
    %450 = llvm.add %449, %167 : i64
    %451 = llvm.getelementptr %31[%450] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %452 = llvm.intr.masked.load %451, %448, %20 {alignment = 4 : i32} : (!llvm.ptr, vector<8xi1>, vector<8xf32>) -> vector<8xf32>
    %453 = llvm.fmul %433, %443 : vector<8xf32>
    %454 = llvm.fadd %452, %453 : vector<8xf32>
    %455 = llvm.sub %8, %167 : i64
    %456 = llvm.trunc %455 : i64 to i32
    %457 = llvm.insertelement %456, %0[%1 : i32] : vector<8xi32>
    %458 = llvm.shufflevector %457, %0 [0, 0, 0, 0, 0, 0, 0, 0] : vector<8xi32> 
    %459 = llvm.icmp "sgt" %458, %19 : vector<8xi32>
    %460 = llvm.mul %164, %8 : i64
    %461 = llvm.add %460, %167 : i64
    %462 = llvm.getelementptr %31[%461] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.intr.masked.store %454, %462, %459 {alignment = 4 : i32} : vector<8xf32>, vector<8xi1> into !llvm.ptr
    %463 = llvm.add %167, %10 : i64
    llvm.br ^bb58(%463 : i64)
  ^bb60:  // pred: ^bb58
    %464 = llvm.add %164, %11 : i64
    llvm.br ^bb56(%464 : i64)
  ^bb61:  // pred: ^bb56
    %465 = llvm.add %161, %10 : i64
    llvm.br ^bb54(%465 : i64)
  ^bb62:  // pred: ^bb54
    %466 = llvm.add %159, %9 : i64
    llvm.br ^bb53(%466 : i64)
  ^bb63:  // pred: ^bb53
    %467 = llvm.add %157, %9 : i64
    llvm.br ^bb52(%467 : i64)
  ^bb64:  // pred: ^bb52
    %468 = llvm.call @get_time() : () -> i64
    %469 = llvm.sub %468, %156 : i64
    llvm.call @print_gflops(%6, %6, %6, %469) : (i64, i64, i64, i64) -> ()
    llvm.return %38 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.addressof @__constant_4096x4096xf32_0 : !llvm.ptr
    %1 = llvm.mlir.constant(3735928559 : index) : i64
    %2 = llvm.mlir.addressof @__constant_4096x4096xf32 : !llvm.ptr
    %3 = llvm.mlir.constant(true) : i1
    %4 = llvm.mlir.constant(0 : index) : i64
    %5 = llvm.mlir.constant(8.192000e+03 : f32) : f32
    %6 = llvm.mlir.constant(4096 : index) : i64
    %7 = llvm.mlir.constant(1 : index) : i64
    %8 = llvm.getelementptr %2[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<4096 x array<4096 x f32>>
    %9 = llvm.inttoptr %1 : i64 to !llvm.ptr
    %10 = llvm.getelementptr %0[0, 0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<4096 x array<4096 x f32>>
    %11 = llvm.inttoptr %1 : i64 to !llvm.ptr
    %12 = llvm.call @matmul_4096(%9, %8, %4, %6, %6, %6, %7, %11, %10, %4, %6, %6, %6, %7) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %13 = llvm.extractvalue %12[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.mul %4, %6 overflow<nsw, nuw> : i64
    %15 = llvm.add %14, %4 overflow<nsw, nuw> : i64
    %16 = llvm.getelementptr inbounds|nuw %13[%15] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %17 = llvm.load %16 : !llvm.ptr -> f32
    %18 = llvm.fcmp "oeq" %17, %5 : f32
    %19 = llvm.xor %18, %3 : i1
    %20 = llvm.zext %19 : i1 to i32
    %21 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @free(%21) : (!llvm.ptr) -> ()
    llvm.return %20 : i32
  }
}

