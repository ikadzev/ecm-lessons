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

.macro check_num_a0 # ASCII to hex from a0
	slti t6, a0, '0' # not a number
	bne zero, t6, error
	li t6, '0'
	sub a0, a0, t6 # now dec in a0
	slti t6, a0, 10 # if 0-9
	bne zero, t6, end_check
	slti t6, a0, 17 # NaN
	bne zero, t6, error
	addi a0, a0, -17 # now HEX in a0
	slti t6, a0, 6 # if A-F
	bne zero, t6, end_hex_check
	slti t6, a0, 32 # NaN
	bne zero, t6, error
	addi a0, a0, -32 # now hex in a0
	slti t6, a0, 6 # if a-f
	bne, zero, t6, end_hex_check
	j error # not a number
end_hex_check:
	addi a0, a0, 10
end_check:
.end_macro

main:
	call read_num
	mv t3, t0
	call read_num
	mv t4, t0
	readch # read_sym
	li t6, 0x26
	beq a0, t6, and_num # &
	li t6, 0x2B
	beq a0, t6, add_num # +
	li t6, 0x2D
	beq a0, t6, sub_num # -
	li t6, 0x7C
	beq a0, t6, or_num # I
	j error
after_func:
	li a0, 10
	printch
	call print_num
	exit 0

read_num: # int read_num() - > t0
	li t0, 0
start_read_num:
	readch
	li t6, 10
	beq a0, t6 end_read_num
	check_num_a0
	slli t0, t0, 4
	add t0, t0, a0
	j start_read_num
end_read_num:
	ret

add_num:
	add t0, t3, t4
	j after_func

and_num:
	and t0, t3, t4
	j after_func

sub_num:
	sub t0, t3, t4
	j after_func

or_num:
	or t0, t3, t4
	j after_func
	
print_num: # void print_num(hex in t0): prints number
	li t3, 0xF0000000 # mask
	li t5, 1 # counter
	li t4, 8 # 8th register
start_loop:
	and a0, t3, t0 # get t5-th ch
	bnez a0, end_loop # if t5-th ch is not zero - continue
	beq t4, t5, print_zero # if t0 is zero - print 0
	srli t3, t3, 4 # shift mask
	addi t5, t5, 1 # cnt++
	j start_loop
end_loop: # in a0 - 1st digit of num
start_num_print_loop:
	sub t1, t4, t5 #recover_num
	li t2, 1
	beqz t1, end_recover_loop
recover_loop:
	srli a0, a0, 4
	sub t1, t1, t2
	bnez t1, recover_loop
end_recover_loop:
	slti t6, a0, 10
	beqz t6, recover_hex
	addi a0, a0, '0'
	j end_recover
recover_hex:
	addi a0, a0, 'A'
end_recover:
	printch
	srli t3, t3, 4
	and a0, t3, t0
	addi t5, t5, 1
	ble t5, t4, start_num_print_loop
	ret
	
print_zero:
	li a0, '0'
	printch
	exit 0

error:
	exit 1
