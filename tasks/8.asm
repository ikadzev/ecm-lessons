.include "funcs.asm"

main:
	call read_dec
	mv s0, a0
	call read_dec
	mv s1, a0
	readch
	beqi a0, 0x2A, multing
	beqi a0, 0x2B, adding
	beqi a0, 0x2D, subing
	j error
multing:
	mv a1, s0
	mv a2, s1
	call mult
	j continue
adding:
	add a0, s0, s1
	j continue
subing:
	sub a0, s0, s1
	j continue
continue:
	mv s0, a0
	li a0, 10
	printch
	mv a0, s0
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
	

