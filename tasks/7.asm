.macro syscall %t
	li a7, %t
	ecall
.end_macro

.macro exit %ecode
	li a0, %ecode
	syscall 93
.end_macro

.macro readch
	syscall 12
.end_macro 

.macro printch
	syscall 11
.end_macro

.macro check_num %num, %temp # ASCII to hex
	slti %temp, %num, '0' # not a number
	bnez %temp, error
	li %temp, '0'
	sub %num, %num, %temp # now dec in a0
	slti %temp, %num, 10 # if 0-9
	beqz %temp, error
.end_macro

.macro push %r
	addi sp, sp -4
	sw %r, 0(sp)
.end_macro

.macro pop %r
	lw %r, 0(sp)
	addi sp, sp, 4
.end_macro

main:
	call read_dec
	call print_dec
	exit 0

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
	li a0, 0
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

read_num:
	li t1, 0
start_read_num:
	readch
	li t0, 10
	beq a0, t0, end_read_num
	check_num a0, t0
	slli t1, t1, 4
	add t1, t1, a0
	j start_read_num
end_read_num:
	mv a0, t1
	ret

my_div:
	slti t6, a0, 10
	bnez t6, return_zero
	srli t0, a0, 2
	srli a0, a0, 1
	push ra
	push t0
	call my_div
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
	

	
print_num: # void print_num(hex in a0): prints number
	mv a1, a0 # in a0 - digit, in a1 - number
	li t6, 0xF0000000 # mask
	li t5, 1 # counter
	li t4, 8 # 8th register
start_loop:
	and a0, t6, a1 # get t6-th ch
	bnez a0, end_loop # if t6-th ch is not zero - continue
	bne t4, t5, not_zero # if a0 is zero - print 0
	li a0, '0'
	printch
	ret
not_zero:
	srli t6, t6, 4 # shift mask
	addi t5, t5, 1 # cnt++
	j start_loop
end_loop: # in a0 - 1st digit of num
start_num_print_loop:
	sub t0, t4, t5
	slli t0, t0, 2
	srl a0, a0, t0
	slti t0, a0, 10
	beqz t0, recover_hex
	addi a0, a0, '0' # recover decimal
	j end_recover
recover_hex:
	addi a0, a0, 'A' # recover hex
end_recover:
	printch
	srli t6, t6, 4
	and a0, t6, a1
	addi t5, t5, 1
	ble t5, t4, start_num_print_loop
	ret
	
error:
	exit 1
