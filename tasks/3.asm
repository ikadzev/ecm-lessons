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

.macro check_num %num, %temp # ASCII to hex from a0
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
	addi sp, sp -4
	sw %r, 0(sp)
.end_macro

.macro pop %r
	lw %r, 0(sp)
	addi sp, sp, 4
.end_macro

main:
	call read_num
	mv a1, a0
	call read_num
	mv a2, a0
	readch # read_sym
	li t0, 0x26
	beq a0, t0, and_num # &
	li t0, 0x2B
	beq a0, t0, add_num # +
	li t0, 0x2D
	beq a0, t0, sub_num # -
	li t0, 0x7C
	beq a0, t0, or_num # I
	j error
after_func:
	mv t0, a0
	li a0, 10
	printch
	mv a0, t0
	call print_num
	exit 0

read_num: # int read_num() - > a0
	push s0
	push s1
	push s2
start_read_num:
	readch
	li s0, 10
	beq a0, s0 end_read_num
	check_num a0, s2
	slli s1, s1, 4
	add s1, s1, a0
	j start_read_num
end_read_num:
	mv a0, s1
	pop s2
	pop s1
	pop s0
	ret

add_num:
	add a0, a1, a2
	j after_func

and_num:
	and a0, a1, a2
	j after_func

sub_num:
	sub a0, a1, a2
	j after_func

or_num:
	or a0, a1, a2
	j after_func
	
print_num: # void print_num(hex in t0): prints number
	mv a1, a0 # in a0 - digit, in a1 - number
	li t6, 0xF0000000 # mask
	li t5, 1 # counter
	li t4, 8 # 8th register
start_loop:
	and a0, t6, a1 # get t6-th ch
	bnez a0, end_loop # if t6-th ch is not zero - continue
	beq t4, t5, print_zero # if a0 is zero - print 0
	srli t6, t6, 4 # shift mask
	addi t5, t5, 1 # cnt++
	j start_loop
end_loop: # in a0 - 1st digit of num
start_num_print_loop:
	sub t0, t4, t5
recover_loop:
	beqz t0, end_recover_loop
	srli a0, a0, 4
	addi t0, t0, -1
	j recover_loop
end_recover_loop:
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
	
print_zero:
	li a0, '0'
	printch
	exit 0

error:
	exit 1
