j random_name_for_jump
.macro sys %t
	li a7, %t
	ecall
.end_macro

.macro exit %ecode
	li a0, %ecode
	sys 93
.end_macro

.macro readch
	sys 12
.end_macro 

.macro printch
	sys 11
.end_macro

.macro check_num %num, %temp # ASCII to hex
	slti %temp, %num, '0' # not a number
	bnez %temp, error
	li %temp, '0'
	sub %num, %num, %temp # now dec in a0
	slti %temp, %num, 10 # if 0-9
	bnez %temp, end_check
	slti %temp, %num, 17 # NaN
	bnez %temp, error
	addi %num, %num, -17 # now HEX in a0
	slti %temp, %num, 6 # if A-F
	bnez %temp, end_hex_check
	slti %temp, %num, 32 # NaN
	bnez %temp, error
	addi %num, %num, -32 # now hex in a0
	slti %temp, %num, 6 # if a-f
	bnez %temp, end_hex_check
	j error # not a number
end_hex_check:
	addi %num, %num, 10
end_check:
.end_macro

.macro push %r
	addi sp, sp, -4
	sw %r, 0(sp)
.end_macro

.macro pop %r
	lw %r, 0(sp)
	addi sp, sp, 4
.end_macro

.macro beqi %reg, %imm, %branch
	li t0, %imm
	beq %reg, t0, %branch
.end_macro

.macro prstr %str
	push	a0
	mv	a0, %str
	sys	4
	pop	a0
.end_macro

.macro pstr %str
.data
	str: .asciz %str
.text
	push	a0
	la 	a0, str
	sys	4
	pop	a0
.end_macro

.macro pstrln %str
	push a0
	pstr %str
	li a0, 10
	printch
	pop a0
.end_macro

.macro pch %char
	push a0
	li a0, %char
	sys 11
	pop a0
.end_macro

.macro pint %int
	push a0
	li a0, %int
	sys 1
	pop a0
.end_macro

.macro print_int_ln %int %line
	push a0	
	mv a0, %int
	sys 1
	pch 9
	prstr %line
	pstrln ""
	pop a0
.end_macro

read_dec:
	li t1, 0
start_read_dec:
	readch
	li t0, 10
	beq a0, t0, end_read_dec
	check_num a0, t2
	mv a1, t1
	mv a2, t0
	push ra
	push a0
	call mult
	mv a1, a0
	pop a0
	pop ra
	mv t1, a1
	add t1, t1, a0
	j start_read_dec
end_read_dec:
	mv a0, t1
	ret
	
print_dec:
	li t0, -1
	push t0
	bne a0,  zero, start_print_dec
	li a0, '0'
	printch
	ret
start_print_dec:
	mv a1, a0
	push ra
	push a1
	call my_mod
	pop a1
	pop ra
	push a0
	mv a0, a1
	push ra
	call my_div
	pop ra
	bne a0, zero, start_print_dec
print_dec_loop:
	li t0, -1
	pop a0
	beq a0, t0, end_print_dec
	addi a0, a0, '0'
	printch
	j print_dec_loop
end_print_dec:
	ret

my_div:
	push s0
	mv s0, a0
	push ra
	call my_div_inner
	pop ra
	mv s1, a0
	mv a1, a0
	li a2, 10
	push ra
	call mult
	pop ra
	bgt s0, a0, end_my_div
	addi s1, s1, -1
end_my_div:
	mv a0, s1
	pop s0
	ret
	
my_div_inner:
	slti t6, a0, 10
	bnez t6, return_zero
	srli t0, a0, 2
	srli a0, a0, 1
	push ra
	push t0
	call my_div_inner
	pop t0
	pop ra
	sub a0, t0, a0
	srli a0, a0, 1
	ret
return_zero:
	mv a0, zero
	ret
	 
my_mod:
	mv t6, a0
	push ra
	push t6
	call my_div
	pop t6
	pop ra
	mv a1, a0
	li a2, 10
	push t6
	push ra
	call mult
	pop ra
	pop t6
	sub a0, t6, a0
	ret

mult:
	li a0, 0
	li t0, 1
	li t1, -1
	li t2, 32
start_mult:
	addi t1, t1, 1
	sll t3, t0, t1
	and t6, a2, t3
	beq t1, t2, end_mult
	beqz t6, start_mult
	sll t3, a1, t1
	add a0, a0, t3
	j start_mult
end_mult:
	ret
	
strchr:
	addi a0, a0, -1
sc_loop:
	addi a0, a0, 1
	lb t0, 0(a0)
	beq t0, zero, sc_zero
	beq t0, a1, sc_end
	j sc_loop
sc_zero:
	li a0, 0
sc_end:
	ret

find_len:
	push	s0
	push	s1
	push	s2
	li 	s2, -1 # error_code
	mv 	s0, a0
	li 	a1, 0
	li	a2, 2
	sys	62
	beq	a0, s2, len_error1
	mv	s1, a0
	mv	a0, s0
	li	a1, 0
	li	a2, 0
	sys	62
	beq	a0, s2, len_error2
	mv	a0, s1
	pop 	s2
	pop 	s1
	pop 	s0
	ret
len_error1:
	pstr "Failed finding length(1)"
	exit 1
len_error2:
	pstr "Failed finding length(2)"
	exit 1
	
open:
	li 	a1, 0
	sys	1024
	li 	t0, -1
	beq 	a0, t0, open_error
	ret
open_error:
	pstr "Failed to open file"
	exit 1
		
close:
	sys	57
	ret

load:
	push ra
	mv t0, a0
	mv t1, a1
	mv a0, a1
	addi a0, a0, 1
	sys 9
	li t6, -1
	beq a0, t6, error
	mv t2, a0
	add t3, a0, t1
	sb zero, 1(t3)
	mv a1, a0
	mv a0, t0
	mv a2, t1
	call read
	mv a0, t2
	pop ra
	ret
	
read:
	push s0
	mv s0, a2
	sys 63
	bne a0, s0, r_error
	pop s0
	ret
r_error:
	pstr "Error while reading file"
	exit 1
	
cntln:
	push ra
	push s0
	li s0, 0
	addi a0, a0, -1
cntln_loop:
	addi s0, s0, 1
	addi a0, a0, 1
	li a1, '\n'
	call strchr
	bnez a0, cntln_loop
	mv a0, s0
	pop s0
	pop ra
	ret	
	
error:
	pstr "Error"
	exit 1
	
random_name_for_jump:
