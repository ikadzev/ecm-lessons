.include "funcs.asm"

.macro pln %int %line
	push a0	
	mv a0, %int
	sys 1
	pch 9
	prstr %line
	pstrln ""
	pop a0
.end_macro

main:
	li t0, 1
	li s4, -1
	beq a0, t0, cat

	push a0
	push a1
	lw a0, 4(a1)
	call rint
	mv s4, a0
	pop a1
	pop a0
	
	li t0, 2
	beq a0, t0, cat
	pstrln "Wrong arguments"
	exit 1
cat:
	lw a0, 0(a1)
	call open
	mv s0, a0
	call find_len
	mv a1, a0
	mv a0, s0
	call load
	call split_lines
	li s0, 1 # counter
	mv s1, a0 # array of lines
	addi s2, a1, 1 # max_cnt
	li t0, -1
	beq s4, t0, cat_loop
	sub s5, s2, s4
cat_loop:
	bge s0, s2, cat_end
	lw s3, 0(s1)
	blt s0, s5, cat_skip
	pln s0, s3
cat_skip:
	addi s0, s0, 1
	addi s1, s1, 4
	j cat_loop
cat_end:
	exit 0

rint:
	push ra
	push s0
	push s1
	mv s0, a0
	li s1, 0
	lb s2, 0(s0)
rint_loop:
	beqz s2, rint_end
	check_num s2, t0
	mv a1, s1
	li a2, 10
	call mult
	add s1, a0, s2
	addi s0, s0, 1
	lb s2, 0(s0)
	j rint_loop
rint_end:
	mv a0, s1
	pop s1
	pop s0
	pop ra
	ret
			
split_lines: # a0 - fd
	push ra
	push s0
	push s1
	push s2
	push s3
	mv s0, a0 # fd
	call cntln
	mv s1, a0 # len
	slli a0, a0, 2
	sys 9 # sbrk
	mv s2, a0 # array of lines
	mv s3, a0 # counter
	mv a0, s0
	li a1, 10
	call strchr
split_loop:
	beqz a0, split_loop_end
	sb zero, 0(a0)
	sw s0, 0(s3)
	addi s3, s3, 4
	addi a0, a0, 1
	mv s0, a0
	li a1, 10
	call strchr
	j split_loop
split_loop_end:
	sw s0, 0(s3)
	mv a0, s2
	mv a1, s1
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret
	