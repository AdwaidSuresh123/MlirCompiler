; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13) {
  %15 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %7, 0
  %16 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %15, ptr %8, 1
  %17 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %16, i64 %9, 2
  %18 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %17, i64 %10, 3, 0
  %19 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %18, i64 %12, 4, 0
  %20 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %19, i64 %11, 3, 1
  %21 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %20, i64 %13, 4, 1
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %0, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, ptr %1, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %2, 2
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %3, 3, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %5, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %4, 3, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %6, 4, 1
  %29 = call ptr @malloc(i64 65600)
  %30 = ptrtoint ptr %29 to i64
  %31 = add i64 %30, 63
  %32 = urem i64 %31, 64
  %33 = sub i64 %31, %32
  %34 = inttoptr i64 %33 to ptr
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %29, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %34, 1
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 0, 2
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 128, 3, 0
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, i64 128, 3, 1
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, i64 128, 4, 0
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 1, 4, 1
  br label %42

42:                                               ; preds = %74, %14
  %43 = phi i64 [ %75, %74 ], [ 0, %14 ]
  %44 = icmp slt i64 %43, 128
  br i1 %44, label %45, label %76

45:                                               ; preds = %42
  br label %46

46:                                               ; preds = %72, %45
  %47 = phi i64 [ %73, %72 ], [ 0, %45 ]
  %48 = icmp slt i64 %47, 128
  br i1 %48, label %49, label %74

49:                                               ; preds = %46
  %50 = add i64 %43, 64
  br label %51

51:                                               ; preds = %70, %49
  %52 = phi i64 [ %71, %70 ], [ %43, %49 ]
  %53 = icmp slt i64 %52, %50
  br i1 %53, label %54, label %72

54:                                               ; preds = %51
  %55 = add i64 %47, 64
  br label %56

56:                                               ; preds = %59, %54
  %57 = phi i64 [ %69, %59 ], [ %47, %54 ]
  %58 = icmp slt i64 %57, %55
  br i1 %58, label %59, label %70

59:                                               ; preds = %56
  %60 = sub i64 128, %57
  %61 = trunc i64 %60 to i32
  %62 = insertelement <8 x i32> poison, i32 %61, i32 0
  %63 = shufflevector <8 x i32> %62, <8 x i32> poison, <8 x i32> zeroinitializer
  %64 = icmp sgt <8 x i32> %63, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %65 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %66 = mul i64 %52, 128
  %67 = add i64 %66, %57
  %68 = getelementptr float, ptr %65, i64 %67
  call void @llvm.masked.store.v8f32.p0(<8 x float> zeroinitializer, ptr %68, i32 4, <8 x i1> %64)
  %69 = add i64 %57, 8
  br label %56

70:                                               ; preds = %56
  %71 = add i64 %52, 1
  br label %51

72:                                               ; preds = %51
  %73 = add i64 %47, 64
  br label %46

74:                                               ; preds = %46
  %75 = add i64 %43, 64
  br label %42

76:                                               ; preds = %42
  br label %77

77:                                               ; preds = %152, %76
  %78 = phi i64 [ %153, %152 ], [ 0, %76 ]
  %79 = icmp slt i64 %78, 128
  br i1 %79, label %80, label %154

80:                                               ; preds = %77
  br label %81

81:                                               ; preds = %150, %80
  %82 = phi i64 [ %151, %150 ], [ 0, %80 ]
  %83 = icmp slt i64 %82, 128
  br i1 %83, label %84, label %152

84:                                               ; preds = %81
  br label %85

85:                                               ; preds = %148, %84
  %86 = phi i64 [ %149, %148 ], [ 0, %84 ]
  %87 = icmp slt i64 %86, 128
  br i1 %87, label %88, label %150

88:                                               ; preds = %85
  %89 = add i64 %78, 64
  br label %90

90:                                               ; preds = %146, %88
  %91 = phi i64 [ %147, %146 ], [ %78, %88 ]
  %92 = icmp slt i64 %91, %89
  br i1 %92, label %93, label %148

93:                                               ; preds = %90
  %94 = add i64 %82, 64
  br label %95

95:                                               ; preds = %144, %93
  %96 = phi i64 [ %145, %144 ], [ %82, %93 ]
  %97 = icmp slt i64 %96, %94
  br i1 %97, label %98, label %146

98:                                               ; preds = %95
  %99 = add i64 %86, 32
  br label %100

100:                                              ; preds = %103, %98
  %101 = phi i64 [ %143, %103 ], [ %86, %98 ]
  %102 = icmp slt i64 %101, %99
  br i1 %102, label %103, label %144

103:                                              ; preds = %100
  %104 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %105 = mul i64 %91, 128
  %106 = add i64 %105, %101
  %107 = getelementptr float, ptr %104, i64 %106
  %108 = load <1 x float>, ptr %107, align 4
  %109 = extractelement <1 x float> %108, i64 0
  %110 = insertelement <8 x float> poison, float %109, i32 0
  %111 = shufflevector <8 x float> %110, <8 x float> poison, <8 x i32> zeroinitializer
  %112 = sub i64 128, %96
  %113 = trunc i64 %112 to i32
  %114 = insertelement <8 x i32> poison, i32 %113, i32 0
  %115 = shufflevector <8 x i32> %114, <8 x i32> poison, <8 x i32> zeroinitializer
  %116 = icmp sgt <8 x i32> %115, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %117 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, 1
  %118 = mul i64 %101, 128
  %119 = add i64 %118, %96
  %120 = getelementptr float, ptr %117, i64 %119
  %121 = call <8 x float> @llvm.masked.load.v8f32.p0(ptr %120, i32 4, <8 x i1> %116, <8 x float> undef)
  %122 = sub i64 128, %96
  %123 = trunc i64 %122 to i32
  %124 = insertelement <8 x i32> poison, i32 %123, i32 0
  %125 = shufflevector <8 x i32> %124, <8 x i32> poison, <8 x i32> zeroinitializer
  %126 = icmp sgt <8 x i32> %125, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %127 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %128 = mul i64 %91, 128
  %129 = add i64 %128, %96
  %130 = getelementptr float, ptr %127, i64 %129
  %131 = call <8 x float> @llvm.masked.load.v8f32.p0(ptr %130, i32 4, <8 x i1> %126, <8 x float> undef)
  %132 = fmul <8 x float> %111, %121
  %133 = fadd <8 x float> %131, %132
  %134 = sub i64 128, %96
  %135 = trunc i64 %134 to i32
  %136 = insertelement <8 x i32> poison, i32 %135, i32 0
  %137 = shufflevector <8 x i32> %136, <8 x i32> poison, <8 x i32> zeroinitializer
  %138 = icmp sgt <8 x i32> %137, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %139 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, 1
  %140 = mul i64 %91, 128
  %141 = add i64 %140, %96
  %142 = getelementptr float, ptr %139, i64 %141
  call void @llvm.masked.store.v8f32.p0(<8 x float> %133, ptr %142, i32 4, <8 x i1> %138)
  %143 = add i64 %101, 1
  br label %100

144:                                              ; preds = %100
  %145 = add i64 %96, 8
  br label %95

146:                                              ; preds = %95
  %147 = add i64 %91, 1
  br label %90

148:                                              ; preds = %90
  %149 = add i64 %86, 32
  br label %85

150:                                              ; preds = %85
  %151 = add i64 %82, 64
  br label %81

152:                                              ; preds = %81
  %153 = add i64 %78, 64
  br label %77

154:                                              ; preds = %77
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %41
}

define i32 @main() {
  %1 = call ptr @malloc(i64 65600)
  %2 = ptrtoint ptr %1 to i64
  %3 = add i64 %2, 63
  %4 = urem i64 %3, 64
  %5 = sub i64 %3, %4
  %6 = inttoptr i64 %5 to ptr
  %7 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %1, 0
  %8 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %7, ptr %6, 1
  %9 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %8, i64 0, 2
  %10 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %9, i64 128, 3, 0
  %11 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %10, i64 128, 3, 1
  %12 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %11, i64 128, 4, 0
  %13 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %12, i64 1, 4, 1
  br label %14

14:                                               ; preds = %46, %0
  %15 = phi i64 [ %47, %46 ], [ 0, %0 ]
  %16 = icmp slt i64 %15, 128
  br i1 %16, label %17, label %48

17:                                               ; preds = %14
  br label %18

18:                                               ; preds = %44, %17
  %19 = phi i64 [ %45, %44 ], [ 0, %17 ]
  %20 = icmp slt i64 %19, 128
  br i1 %20, label %21, label %46

21:                                               ; preds = %18
  %22 = add i64 %15, 64
  br label %23

23:                                               ; preds = %42, %21
  %24 = phi i64 [ %43, %42 ], [ %15, %21 ]
  %25 = icmp slt i64 %24, %22
  br i1 %25, label %26, label %44

26:                                               ; preds = %23
  %27 = add i64 %19, 64
  br label %28

28:                                               ; preds = %31, %26
  %29 = phi i64 [ %41, %31 ], [ %19, %26 ]
  %30 = icmp slt i64 %29, %27
  br i1 %30, label %31, label %42

31:                                               ; preds = %28
  %32 = sub i64 128, %29
  %33 = trunc i64 %32 to i32
  %34 = insertelement <8 x i32> poison, i32 %33, i32 0
  %35 = shufflevector <8 x i32> %34, <8 x i32> poison, <8 x i32> zeroinitializer
  %36 = icmp sgt <8 x i32> %35, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %37 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 1
  %38 = mul i64 %24, 128
  %39 = add i64 %38, %29
  %40 = getelementptr float, ptr %37, i64 %39
  call void @llvm.masked.store.v8f32.p0(<8 x float> splat (float 1.000000e+00), ptr %40, i32 4, <8 x i1> %36)
  %41 = add i64 %29, 8
  br label %28

42:                                               ; preds = %28
  %43 = add i64 %24, 1
  br label %23

44:                                               ; preds = %23
  %45 = add i64 %19, 64
  br label %18

46:                                               ; preds = %18
  %47 = add i64 %15, 64
  br label %14

48:                                               ; preds = %14
  %49 = call ptr @malloc(i64 65600)
  %50 = ptrtoint ptr %49 to i64
  %51 = add i64 %50, 63
  %52 = urem i64 %51, 64
  %53 = sub i64 %51, %52
  %54 = inttoptr i64 %53 to ptr
  %55 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %49, 0
  %56 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, ptr %54, 1
  %57 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %56, i64 0, 2
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %57, i64 128, 3, 0
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, i64 128, 3, 1
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 128, 4, 0
  %61 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, i64 1, 4, 1
  br label %62

62:                                               ; preds = %94, %48
  %63 = phi i64 [ %95, %94 ], [ 0, %48 ]
  %64 = icmp slt i64 %63, 128
  br i1 %64, label %65, label %96

65:                                               ; preds = %62
  br label %66

66:                                               ; preds = %92, %65
  %67 = phi i64 [ %93, %92 ], [ 0, %65 ]
  %68 = icmp slt i64 %67, 128
  br i1 %68, label %69, label %94

69:                                               ; preds = %66
  %70 = add i64 %63, 64
  br label %71

71:                                               ; preds = %90, %69
  %72 = phi i64 [ %91, %90 ], [ %63, %69 ]
  %73 = icmp slt i64 %72, %70
  br i1 %73, label %74, label %92

74:                                               ; preds = %71
  %75 = add i64 %67, 64
  br label %76

76:                                               ; preds = %79, %74
  %77 = phi i64 [ %89, %79 ], [ %67, %74 ]
  %78 = icmp slt i64 %77, %75
  br i1 %78, label %79, label %90

79:                                               ; preds = %76
  %80 = sub i64 128, %77
  %81 = trunc i64 %80 to i32
  %82 = insertelement <8 x i32> poison, i32 %81, i32 0
  %83 = shufflevector <8 x i32> %82, <8 x i32> poison, <8 x i32> zeroinitializer
  %84 = icmp sgt <8 x i32> %83, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %85 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 1
  %86 = mul i64 %72, 128
  %87 = add i64 %86, %77
  %88 = getelementptr float, ptr %85, i64 %87
  call void @llvm.masked.store.v8f32.p0(<8 x float> splat (float 2.000000e+00), ptr %88, i32 4, <8 x i1> %84)
  %89 = add i64 %77, 8
  br label %76

90:                                               ; preds = %76
  %91 = add i64 %72, 1
  br label %71

92:                                               ; preds = %71
  %93 = add i64 %67, 64
  br label %66

94:                                               ; preds = %66
  %95 = add i64 %63, 64
  br label %62

96:                                               ; preds = %62
  %97 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 0
  %98 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 1
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 2
  %100 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 3, 0
  %101 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 3, 1
  %102 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 4, 0
  %103 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %13, 4, 1
  %104 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 0
  %105 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 1
  %106 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 2
  %107 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 3, 0
  %108 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 3, 1
  %109 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 4, 0
  %110 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %61, 4, 1
  %111 = call { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul(ptr %97, ptr %98, i64 %99, i64 %100, i64 %101, i64 %102, i64 %103, ptr %104, ptr %105, i64 %106, i64 %107, i64 %108, i64 %109, i64 %110)
  ret i32 0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare <8 x float> @llvm.masked.load.v8f32.p0(ptr captures(none), i32 immarg, <8 x i1>, <8 x float>) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.masked.store.v8f32.p0(<8 x float>, ptr captures(none), i32 immarg, <8 x i1>) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
