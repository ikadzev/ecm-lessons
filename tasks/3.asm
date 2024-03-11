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

.macro check_num
	slti t6, a0, '0' # not a number
	bne zero, t6, error
	li t6, '0'
	sub a0, a0, t6 # now num in a0
	slti t6, a0, 10 # if 0-9
	bne zero, t6, end_check
	slti t6, a0, 17 # not a number
	bne zero, t6, error
	li t6, 17
	sub a0, a0, t6 # now hex in a0
	slti t6, a0, 6 # if A-F
	bne zero, t6, end_hex_check
	slti t6, a0, 32
	bne zero, t6, error
	li t6, 32
	sub a0, a0, t6
	slti t6, a0, 6
	bne, zero, t6, end_hex_check
	beqz t6, error
end_hex_check:
	addi a0, a0, 10
end_check:
.end_macro

.macro read_num %t
start_read_num:
	readch # to a0
	li t6, 10
	beq a0, t6, end_read_num
	check_num # from a0
	slli %t, %t, 4	
	add %t, %t, a0
	j start_read_num
end_read_num:
.end_macro

.macro read_sym
	readch
	li t3, 0
	li t6, 0x26
	beq a0, t6, and_num # &
	li t6, 0x2B
	beq a0, t6, add_num # +
	li t6, 0x2D
	beq a0, t6, sub_num # -
	li t6, 0x7C
	beq a0, t6, or_num # I
	j error
end_read_sym:
.end_macro

.macro recover_num # 0x to ASCII
	li t1, 0
	li t2, 1
	sub t1, t4, t5
	beqz t1, skip_recover_loop
recover_loop:
	srli a0, a0, 4
	sub t1, t1, t2
	bnez t1, recover_loop
skip_recover_loop:
	slti t6, a0, 10
	beqz t6, recover_hex
	addi a0, a0, '0'
	j end_recover
recover_hex:
	addi a0, a0, 'A'
end_recover:
.end_macro

main:
	read_num t1
	read_num t2
	read_sym
	
add_num:
	add t0, t1, t2
	j print_num

and_num:
	and t0, t1, t2
	j print_num

sub_num:
	sub t0, t1, t2
	j print_num

or_num:
	or t0, t1, t2
	j print_num
	
print_num: # result in t0
	li t3, 0xF0000000 # mask
	li t5, 1 # counter
	li t4, 8 # 8th register
	and a0, t3, t0
	bnez a0, end_loop # if 1st ch is not 0
start_loop: #else
	beq t5, t4, print_zero
	srli t3, t3, 4
	addi t5, t5, 1
	and a0, t3, t0
	beqz a0, start_loop
end_loop: # in a0 - 1st num
start_fin_loop:
	recover_num
	printch
	srli t3, t3, 4
	and a0, t3, t0
	addi t5, t5, 1
	bne t5, t4, start_fin_loop
	recover_num
	printch
	exit 0
	
print_zero:
	li a0, '0'
	printch
	exit 0

error:
	exit 1