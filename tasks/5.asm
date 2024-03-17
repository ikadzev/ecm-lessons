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

test:
	j main
	li a1, 4
	li a2, 5
	call mult

main:
	call read_num
	mv s1, a0
	call read_num
	mv s2, a0
	li a0, 10
	printch
	mv a1, s1
	mv a2, s2
	call mult
	call print_num
	exit 0

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
	
	

read_num: # int read_num() - > a0
	li t1, 0
start_read_num:
	readch
	li t0, 10
	beq a0, t0 end_read_num
	check_num a0, t0
	slli t1, t1, 4
	add t1, t1, a0
	j start_read_num
end_read_num:
	mv a0, t1
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