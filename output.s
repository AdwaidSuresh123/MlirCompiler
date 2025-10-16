	.file	"LLVMDialectModule"
	.text
	.globl	matmul                          # -- Begin function matmul
	.p2align	4
	.type	matmul,@function
matmul:                                 # @matmul
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$88, %rsp
	.cfi_def_cfa_offset 144
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rdx, 72(%rsp)                  # 8-byte Spill
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	movq	168(%rsp), %r15
	movl	$65600, %edi                    # imm = 0x10040
	callq	malloc@PLT
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	leaq	63(%rax), %rdx
	andq	$-64, %rdx
	xorl	%ecx, %ecx
	vxorps	%xmm0, %xmm0, %xmm0
	xorl	%eax, %eax
	jmp	.LBB0_1
	.p2align	4
.LBB0_11:                               #   in Loop: Header=BB0_1 Depth=1
	addq	$16384, %rcx                    # imm = 0x4000
	movq	%rsi, %rax
.LBB0_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
                                        #       Child Loop BB0_5 Depth 3
                                        #         Child Loop BB0_8 Depth 4
	cmpq	$127, %rax
	jg	.LBB0_12
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	leaq	32(%rax), %rsi
	movq	%rcx, %rdi
	xorl	%r8d, %r8d
	jmp	.LBB0_3
	.p2align	4
.LBB0_10:                               #   in Loop: Header=BB0_3 Depth=2
	subq	$-128, %rdi
	movq	%r9, %r8
.LBB0_3:                                #   Parent Loop BB0_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_5 Depth 3
                                        #         Child Loop BB0_8 Depth 4
	cmpq	$127, %r8
	jg	.LBB0_11
# %bb.4:                                #   in Loop: Header=BB0_3 Depth=2
	leaq	32(%r8), %r9
	movq	%rdi, %r10
	movq	%rax, %r11
	jmp	.LBB0_5
	.p2align	4
.LBB0_9:                                #   in Loop: Header=BB0_5 Depth=3
	incq	%r11
	addq	$512, %r10                      # imm = 0x200
.LBB0_5:                                #   Parent Loop BB0_1 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_8 Depth 4
	cmpq	%rsi, %r11
	jge	.LBB0_10
# %bb.6:                                #   in Loop: Header=BB0_5 Depth=3
	movq	%r10, %rbx
	movq	%r8, %r14
	cmpq	%r9, %r14
	jge	.LBB0_9
	.p2align	4
.LBB0_8:                                #   Parent Loop BB0_1 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        #       Parent Loop BB0_5 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	vmovups	%xmm0, (%rdx,%rbx)
	addq	$4, %r14
	addq	$16, %rbx
	cmpq	%r9, %r14
	jl	.LBB0_8
	jmp	.LBB0_9
.LBB0_12:
	movq	$0, 8(%rsp)                     # 8-byte Folded Spill
	xorl	%ebx, %ebx
	jmp	.LBB0_13
	.p2align	4
.LBB0_29:                               #   in Loop: Header=BB0_13 Depth=1
	addq	$16384, 8(%rsp)                 # 8-byte Folded Spill
                                        # imm = 0x4000
	movq	16(%rsp), %rbx                  # 8-byte Reload
.LBB0_13:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_15 Depth 2
                                        #       Child Loop BB0_17 Depth 3
                                        #         Child Loop BB0_19 Depth 4
                                        #           Child Loop BB0_21 Depth 5
                                        #             Child Loop BB0_24 Depth 6
	cmpq	$127, %rbx
	jg	.LBB0_30
# %bb.14:                               #   in Loop: Header=BB0_13 Depth=1
	leaq	32(%rbx), %rax
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	xorl	%ecx, %ecx
	xorl	%r11d, %r11d
	movq	%rbx, 56(%rsp)                  # 8-byte Spill
	jmp	.LBB0_15
	.p2align	4
.LBB0_28:                               #   in Loop: Header=BB0_15 Depth=2
	movq	48(%rsp), %rcx                  # 8-byte Reload
	subq	$-128, %rcx
	movq	%r12, %r11
.LBB0_15:                               #   Parent Loop BB0_13 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_17 Depth 3
                                        #         Child Loop BB0_19 Depth 4
                                        #           Child Loop BB0_21 Depth 5
                                        #             Child Loop BB0_24 Depth 6
	cmpq	$127, %r11
	jg	.LBB0_29
# %bb.16:                               #   in Loop: Header=BB0_15 Depth=2
	leaq	32(%r11), %r12
	movq	8(%rsp), %r13                   # 8-byte Reload
	movq	%rcx, 48(%rsp)                  # 8-byte Spill
	movq	%rcx, 24(%rsp)                  # 8-byte Spill
	xorl	%esi, %esi
	movq	%r11, 80(%rsp)                  # 8-byte Spill
	jmp	.LBB0_17
	.p2align	4
.LBB0_27:                               #   in Loop: Header=BB0_17 Depth=3
	addq	$4096, 24(%rsp)                 # 8-byte Folded Spill
                                        # imm = 0x1000
	movq	64(%rsp), %r13                  # 8-byte Reload
	addq	$32, %r13
	movq	%rcx, %rsi
	movq	56(%rsp), %rbx                  # 8-byte Reload
.LBB0_17:                               #   Parent Loop BB0_13 Depth=1
                                        #     Parent Loop BB0_15 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_19 Depth 4
                                        #           Child Loop BB0_21 Depth 5
                                        #             Child Loop BB0_24 Depth 6
	cmpq	$127, %rsi
	jg	.LBB0_28
# %bb.18:                               #   in Loop: Header=BB0_17 Depth=3
	leaq	8(%rsi), %rcx
	movq	%r13, 64(%rsp)                  # 8-byte Spill
	jmp	.LBB0_19
	.p2align	4
.LBB0_26:                               #   in Loop: Header=BB0_19 Depth=4
	incq	%rbx
	addq	$512, %r13                      # imm = 0x200
	movq	80(%rsp), %r11                  # 8-byte Reload
.LBB0_19:                               #   Parent Loop BB0_13 Depth=1
                                        #     Parent Loop BB0_15 Depth=2
                                        #       Parent Loop BB0_17 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB0_21 Depth 5
                                        #             Child Loop BB0_24 Depth 6
	cmpq	16(%rsp), %rbx                  # 8-byte Folded Reload
	jge	.LBB0_27
# %bb.20:                               #   in Loop: Header=BB0_19 Depth=4
	movq	72(%rsp), %rax                  # 8-byte Reload
	addq	%r13, %rax
	movq	%rbx, %r8
	shlq	$7, %r8
	movq	24(%rsp), %r10                  # 8-byte Reload
	jmp	.LBB0_21
	.p2align	4
.LBB0_25:                               #   in Loop: Header=BB0_21 Depth=5
	incq	%r11
	addq	$4, %r10
.LBB0_21:                               #   Parent Loop BB0_13 Depth=1
                                        #     Parent Loop BB0_15 Depth=2
                                        #       Parent Loop BB0_17 Depth=3
                                        #         Parent Loop BB0_19 Depth=4
                                        # =>        This Loop Header: Depth=5
                                        #             Child Loop BB0_24 Depth 6
	cmpq	%r12, %r11
	jge	.LBB0_26
# %bb.22:                               #   in Loop: Header=BB0_21 Depth=5
	leaq	(%r8,%r11), %r14
	xorl	%r9d, %r9d
	movq	%r10, %rbp
	leaq	(%rsi,%r9), %rdi
	cmpq	%rcx, %rdi
	jge	.LBB0_25
	.p2align	4
.LBB0_24:                               #   Parent Loop BB0_13 Depth=1
                                        #     Parent Loop BB0_15 Depth=2
                                        #       Parent Loop BB0_17 Depth=3
                                        #         Parent Loop BB0_19 Depth=4
                                        #           Parent Loop BB0_21 Depth=5
                                        # =>          This Inner Loop Header: Depth=6
	vmovss	(%rax,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
	vmulss	(%r15,%rbp), %xmm0, %xmm0
	vaddss	(%rdx,%r14,4), %xmm0, %xmm0
	vmovss	%xmm0, (%rdx,%r14,4)
	vmovss	4(%rax,%r9,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vmulss	512(%r15,%rbp), %xmm1, %xmm1
	vaddss	%xmm1, %xmm0, %xmm0
	vmovss	%xmm0, (%rdx,%r14,4)
	vmovss	8(%rax,%r9,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vmulss	1024(%r15,%rbp), %xmm1, %xmm1
	vaddss	%xmm1, %xmm0, %xmm0
	vmovss	%xmm0, (%rdx,%r14,4)
	vmovss	12(%rax,%r9,4), %xmm1           # xmm1 = mem[0],zero,zero,zero
	vmulss	1536(%r15,%rbp), %xmm1, %xmm1
	vaddss	%xmm1, %xmm0, %xmm0
	vmovss	%xmm0, (%rdx,%r14,4)
	addq	$2048, %rbp                     # imm = 0x800
	addq	$4, %r9
	leaq	(%rsi,%r9), %rdi
	cmpq	%rcx, %rdi
	jl	.LBB0_24
	jmp	.LBB0_25
.LBB0_30:
	movq	40(%rsp), %rax                  # 8-byte Reload
	movq	32(%rsp), %rcx                  # 8-byte Reload
	movq	%rcx, (%rax)
	movq	%rdx, 8(%rax)
	movl	$128, %ecx
	movq	%rcx, 24(%rax)
	movq	%rcx, 32(%rax)
	movq	%rcx, 40(%rax)
	movl	$1, %ecx
	movq	%rcx, 48(%rax)
	movq	$0, 16(%rax)
	addq	$88, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	matmul, .Lfunc_end0-matmul
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function main
.LCPI1_0:
	.long	0x43800000                      # float 256
	.text
	.globl	main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$88, %rsp
	.cfi_def_cfa_offset 144
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movl	$65600, %edi                    # imm = 0x10040
	callq	malloc@PLT
	movq	%rax, %r15
	leaq	63(%rax), %r14
	andq	$-64, %r14
	xorl	%eax, %eax
	movabsq	$4575657222473777152, %rcx      # imm = 0x3F8000003F800000
	xorl	%edx, %edx
	jmp	.LBB1_1
	.p2align	4
.LBB1_11:                               #   in Loop: Header=BB1_1 Depth=1
	addq	$16384, %rax                    # imm = 0x4000
	movq	%rsi, %rdx
.LBB1_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_3 Depth 2
                                        #       Child Loop BB1_5 Depth 3
                                        #         Child Loop BB1_8 Depth 4
	cmpq	$127, %rdx
	jg	.LBB1_12
# %bb.2:                                #   in Loop: Header=BB1_1 Depth=1
	leaq	32(%rdx), %rsi
	movq	%rax, %rdi
	xorl	%r8d, %r8d
	jmp	.LBB1_3
	.p2align	4
.LBB1_10:                               #   in Loop: Header=BB1_3 Depth=2
	subq	$-128, %rdi
	movq	%r9, %r8
.LBB1_3:                                #   Parent Loop BB1_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB1_5 Depth 3
                                        #         Child Loop BB1_8 Depth 4
	cmpq	$127, %r8
	jg	.LBB1_11
# %bb.4:                                #   in Loop: Header=BB1_3 Depth=2
	leaq	32(%r8), %r9
	movq	%rdi, %r10
	movq	%rdx, %r11
	jmp	.LBB1_5
	.p2align	4
.LBB1_9:                                #   in Loop: Header=BB1_5 Depth=3
	incq	%r11
	addq	$512, %r10                      # imm = 0x200
.LBB1_5:                                #   Parent Loop BB1_1 Depth=1
                                        #     Parent Loop BB1_3 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB1_8 Depth 4
	cmpq	%rsi, %r11
	jge	.LBB1_10
# %bb.6:                                #   in Loop: Header=BB1_5 Depth=3
	movq	%r10, %r12
	movq	%r8, %rbx
	cmpq	%r9, %rbx
	jge	.LBB1_9
	.p2align	4
.LBB1_8:                                #   Parent Loop BB1_1 Depth=1
                                        #     Parent Loop BB1_3 Depth=2
                                        #       Parent Loop BB1_5 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movq	%rcx, (%r14,%r12)
	movq	%rcx, 8(%r14,%r12)
	addq	$4, %rbx
	addq	$16, %r12
	cmpq	%r9, %rbx
	jl	.LBB1_8
	jmp	.LBB1_9
.LBB1_12:
	movl	$65600, %edi                    # imm = 0x10040
	callq	malloc@PLT
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	leaq	63(%rax), %r12
	andq	$-64, %r12
	movl	$128, %eax
	xorl	%ebx, %ebx
	movabsq	$4611686019501129728, %rdx      # imm = 0x4000000040000000
	xorl	%esi, %esi
	jmp	.LBB1_13
	.p2align	4
.LBB1_23:                               #   in Loop: Header=BB1_13 Depth=1
	addq	$16384, %rbx                    # imm = 0x4000
	movq	%rdi, %rsi
	movq	%r10, %r15
.LBB1_13:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_15 Depth 2
                                        #       Child Loop BB1_17 Depth 3
                                        #         Child Loop BB1_20 Depth 4
	cmpq	$127, %rsi
	jg	.LBB1_24
# %bb.14:                               #   in Loop: Header=BB1_13 Depth=1
	movq	%r15, %r10
	leaq	32(%rsi), %rdi
	movq	%rbx, %rcx
	xorl	%r15d, %r15d
	jmp	.LBB1_15
	.p2align	4
.LBB1_22:                               #   in Loop: Header=BB1_15 Depth=2
	subq	$-128, %rcx
	movq	%r11, %r15
.LBB1_15:                               #   Parent Loop BB1_13 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB1_17 Depth 3
                                        #         Child Loop BB1_20 Depth 4
	cmpq	$127, %r15
	jg	.LBB1_23
# %bb.16:                               #   in Loop: Header=BB1_15 Depth=2
	leaq	32(%r15), %r11
	movq	%rcx, %r8
	movq	%rsi, %rbp
	jmp	.LBB1_17
	.p2align	4
.LBB1_21:                               #   in Loop: Header=BB1_17 Depth=3
	incq	%rbp
	addq	$512, %r8                       # imm = 0x200
.LBB1_17:                               #   Parent Loop BB1_13 Depth=1
                                        #     Parent Loop BB1_15 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB1_20 Depth 4
	cmpq	%rdi, %rbp
	jge	.LBB1_22
# %bb.18:                               #   in Loop: Header=BB1_17 Depth=3
	movq	%r8, %r13
	movq	%r15, %r9
	cmpq	%r11, %r9
	jge	.LBB1_21
	.p2align	4
.LBB1_20:                               #   Parent Loop BB1_13 Depth=1
                                        #     Parent Loop BB1_15 Depth=2
                                        #       Parent Loop BB1_17 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movq	%rdx, (%r12,%r13)
	movq	%rdx, 8(%r12,%r13)
	addq	$4, %r9
	addq	$16, %r13
	cmpq	%r11, %r9
	jl	.LBB1_20
	jmp	.LBB1_21
.LBB1_24:
	subq	$8, %rsp
	.cfi_adjust_cfa_offset 8
	leaq	40(%rsp), %rdi
	movl	$128, %r8d
	movl	$128, %r9d
	movq	%r15, %rsi
	movq	%r14, %rdx
	xorl	%ecx, %ecx
	movl	$1, %r10d
	pushq	%r10
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	%r12
	.cfi_adjust_cfa_offset 8
	pushq	64(%rsp)                        # 8-byte Folded Reload
	.cfi_adjust_cfa_offset 8
	movl	$1, %eax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	movl	$128, %eax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	matmul@PLT
	addq	$80, %rsp
	.cfi_adjust_cfa_offset -80
	movq	32(%rsp), %rax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	%r15, 16(%rsp)                  # 8-byte Spill
	movq	40(%rsp), %r15
	vmovss	.LCPI1_0(%rip), %xmm0           # xmm0 = [2.56E+2,0.0E+0,0.0E+0,0.0E+0]
	vcmpneqss	(%r15), %xmm0, %xmm0
	vmovss	%xmm0, 4(%rsp)                  # 4-byte Spill
	movl	$24, %edi
	callq	malloc@PLT
	movq	%rax, %rbp
	movl	$3, %edi
	callq	malloc@PLT
	movq	%rax, %r13
	xorl	%edi, %edi
	callq	malloc@PLT
	movq	%rax, %rbx
	movq	%r14, (%rbp)
	movq	%r12, 8(%rbp)
	movq	%r15, 16(%rbp)
	movw	$257, (%r13)                    # imm = 0x101
	movb	$1, 2(%r13)
	movl	$3, %edi
	callq	malloc@PLT
	movq	%rax, %r14
	xorl	%edi, %edi
	callq	malloc@PLT
	movq	%rax, %r12
	subq	$160, %rsp
	.cfi_adjust_cfa_offset 160
	vxorps	%xmm0, %xmm0, %xmm0
	vmovups	%xmm0, 128(%rsp)
	movq	%rax, 120(%rsp)
	movq	%rax, 112(%rsp)
	movq	%r14, 80(%rsp)
	movq	%r14, 72(%rsp)
	movq	%r13, 40(%rsp)
	movq	%r13, 32(%rsp)
	vmovups	%xmm0, 8(%rsp)
	movq	%rbx, (%rsp)
	movq	$1, 144(%rsp)
	movq	$1, 104(%rsp)
	movq	$3, 96(%rsp)
	movq	$0, 88(%rsp)
	movq	$1, 64(%rsp)
	movq	$3, 56(%rsp)
	movq	$0, 48(%rsp)
	movq	$1, 24(%rsp)
	movl	$3, %ecx
	movl	$1, %r8d
	movq	%rbp, %rdi
	movq	%rbp, %rsi
	xorl	%edx, %edx
	movq	%rbx, %r9
	callq	dealloc_helper@PLT
	addq	$160, %rsp
	.cfi_adjust_cfa_offset -160
	cmpb	$1, (%r14)
	je	.LBB1_25
# %bb.26:
	vmovd	4(%rsp), %xmm0                  # 4-byte Folded Reload
                                        # xmm0 = mem[0],zero,zero,zero
	vmovd	%xmm0, %r15d
	cmpb	$1, 1(%r14)
	je	.LBB1_27
.LBB1_28:
	andl	$1, %r15d
	cmpb	$1, 2(%r14)
	jne	.LBB1_30
.LBB1_29:
	movq	24(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
.LBB1_30:
	movq	%rbp, %rdi
	callq	free@PLT
	movq	%rbx, %rdi
	callq	free@PLT
	movq	%r13, %rdi
	callq	free@PLT
	movq	%r14, %rdi
	callq	free@PLT
	movq	%r12, %rdi
	callq	free@PLT
	movl	%r15d, %eax
	addq	$88, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB1_25:
	.cfi_def_cfa_offset 144
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	free@PLT
	vmovd	4(%rsp), %xmm0                  # 4-byte Folded Reload
                                        # xmm0 = mem[0],zero,zero,zero
	vmovd	%xmm0, %r15d
	cmpb	$1, 1(%r14)
	jne	.LBB1_28
.LBB1_27:
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	free@PLT
	andl	$1, %r15d
	cmpb	$1, 2(%r14)
	je	.LBB1_29
	jmp	.LBB1_30
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.globl	dealloc_helper                  # -- Begin function dealloc_helper
	.p2align	4
	.type	dealloc_helper,@function
dealloc_helper:                         # @dealloc_helper
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	168(%rsp), %rax
	movq	128(%rsp), %rdx
	movq	88(%rsp), %rdi
	movq	48(%rsp), %r8
	movq	64(%rsp), %r9
	movq	%rcx, -8(%rsp)
	movq	%r9, -16(%rsp)
	xorl	%r10d, %r10d
	cmpq	%r9, %r10
	jge	.LBB2_3
	.p2align	4
.LBB2_2:                                # =>This Inner Loop Header: Depth=1
	movb	$0, (%rax,%r10)
	incq	%r10
	cmpq	%r9, %r10
	jl	.LBB2_2
.LBB2_3:
	xorl	%r10d, %r10d
	jmp	.LBB2_4
	.p2align	4
.LBB2_13:                               #   in Loop: Header=BB2_4 Depth=1
	andb	%bl, %r11b
	andb	$1, %r11b
	movb	%r11b, (%rdx,%r10)
	incq	%r10
.LBB2_4:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_6 Depth 2
                                        #     Child Loop BB2_12 Depth 2
	cmpq	%rcx, %r10
	jge	.LBB2_14
# %bb.5:                                #   in Loop: Header=BB2_4 Depth=1
	movq	(%rsi,%r10,8), %r14
	movzbl	(%rdi,%r10), %ebx
	movb	$1, %r11b
	xorl	%r15d, %r15d
	jmp	.LBB2_6
	.p2align	4
.LBB2_9:                                #   in Loop: Header=BB2_6 Depth=2
	cmpq	%r14, %r12
	setne	%bpl
	andb	%bpl, %r11b
	incq	%r15
.LBB2_6:                                #   Parent Loop BB2_4 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpq	%r9, %r15
	jge	.LBB2_10
# %bb.7:                                #   in Loop: Header=BB2_6 Depth=2
	movq	(%r8,%r15,8), %r12
	cmpq	%r14, %r12
	jne	.LBB2_9
# %bb.8:                                #   in Loop: Header=BB2_6 Depth=2
	movzbl	(%rax,%r15), %ebp
	orb	%bl, %bpl
	andb	$1, %bpl
	movb	%bpl, (%rax,%r15)
	jmp	.LBB2_9
	.p2align	4
.LBB2_10:                               #   in Loop: Header=BB2_4 Depth=1
	xorl	%r15d, %r15d
	cmpq	%r10, %r15
	jge	.LBB2_13
	.p2align	4
.LBB2_12:                               #   Parent Loop BB2_4 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpq	%r14, (%rsi,%r15,8)
	setne	%bpl
	andb	%bpl, %r11b
	incq	%r15
	cmpq	%r10, %r15
	jl	.LBB2_12
	jmp	.LBB2_13
.LBB2_14:
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	dealloc_helper, .Lfunc_end2-dealloc_helper
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
