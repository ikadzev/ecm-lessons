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
	slti %temp, %num, '0' # if < '0' -> NaN
	bnez %temp, error
	li %temp, '0'
	sub %num, %num, %temp # now dec in a0
	slti %temp, %num, 10 # if 0-9
	beqz %temp, error # else NaN
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
#	j main
	li a1, 0x34A
	li a2, 0x25A
	call sub_num_func

main:
	call read_num # reading 1st num
	mv s1, a0
	call read_num # reading 2nd num
	mv a2, a0 # 2nd num -> a2
	mv a1, s1 # 1st num -> a1
	readch # reading symbol
	li t0, '&'
	beq a0, t0, and_num
	li t0, '+'
	beq a0, t0, add_num
	li t0, '-'
	beq a0, t0, sub_num
	li t0, '|'
	beq a0, t0, or_num
	j error
add_num:
	call add_num_func
	j after_func
and_num:
	and a0, a1, a2
	j after_func
sub_num:
	sub a0, a1, a2
	j after_func
or_num:
	or a0, a1, a2
after_func:
	mv s0, a0 # ans -> s0
	li a0, 10 # print \n
	printch
	andi t6, s0, 0xF
	srli s0, s0, 4
	beqz s0, to_print_num
	li t5, 11
	bne t6, t5, to_print_num
	li a0, '-'
	printch
to_print_num:
	mv a0, s0
	call print_num
	exit 0

add_num_func:
	li s0, 0xF # mask
	li s1, 1 # digit of num
	li s2, 8 # max digit
	and t1, a1, s0
	and t2, a2, s0
	mv a0, t1
	beq t1, t2, start_add_num # if sign1 == sign2 --> normal sum
	sub a2, a2, t2 # else sign2 = -sign2
	add a2, a2, t1
	push ra
	call start_sub_num # and calling sub
	pop ra
	ret
start_add_num:
	slli t6, s1, 2 # cnt to cnt_bits in t6 
	sll t5, s0, t6 # shifting mask to t5
	and t1, a1, t5 # 1st
	and t2, a2, t5 # 2nd
	add t3, t1, t2  # sum
	srl t3, t3, t6 # shifting sum to smallest bit
	slti t0, t3, 10
	bnez t0, add_dig # if sum < 10 --> normal sum
	li t0, 1 # else
	sll t0, t0, t6
	slli t0, t0, 4 # shifting one to next 4bit
	add a1, a1, t0 # adding one to next 4bit
	addi t3, t3, -10 # adding t3-10 to a0
add_dig:
	sll t3, t3, t6
	add a0, a0, t3
	addi s1, s1, 1
	beq s1, s2, end_add_num
	j start_add_num
end_add_num:
	ret

sub_num_func:
	li s0, 0xF # mask
	li s1, 1 # digit of num
	li s2, 8 # max digit
	and t1, a1, s0
	and t2, a2, s0
	mv a0, t1
	beq t1, t2, start_sub_num # if sign1 == sign2 --> normal sub
	sub a2, a2, t2 # else sign2 = -sign2
	add a2, a2, t1
	push ra
	call start_sub_num # and calling sub
	pop ra
	ret
start_sub_num:
	slli t6, s1, 2 # cnt to cnt_bits in t6 
	sll t5, s0, t6 # shifting mask to t5
	and t1, a1, t5 # 1st
	and t2, a2, t5 # 2nd
	blt t2, t1, sub_dig
	li t3, 10
	sll t3, t3, t6
	add t1, t1, t3
	li t0, 1 # else
	sll t0, t0, s1
	slli t0, t0, 4
	add a1, a1, t0
	# ?
sub_dig:
	sub t3, t1, t2 
	add a0, a0, t3
	addi s1, s1, 1
	beq s1, s2, end_sub_num
	j start_sub_num
end_sub_num:
	ret

read_num: # int read_num() - > a0
	li t1, 0
	li t2, '-'
	li t3, 10# 'A' == '+'
	readch
	bne a0, t2, skip_readch # if 1st symbol is not '-' --> start reading num without reading 1st digit
	li t3, 11 # else 'B' == '-'
start_read_num:
	readch
skip_readch:
	li t0, 10
	beq a0, t0 end_read_num
	check_num a0, t0
	slli t1, t1, 4
	add t1, t1, a0
	j start_read_num
end_read_num:
	slli a0, t1, 4 # shift num for sign
	add a0 ,a0, t3 # adding sign
	ret # in a0 - 0x(num)A if +num and 0x(num)B if -num

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
	sub t0, t4, t5 # counting shift
	slli t0, t0, 2 # shift * 4
	srl a0, a0, t0 # shift digit (0x900 -> 0x009)
	addi a0, a0, '0' # recover decimal
	printch
	srli t6, t6, 4 # shift mask
	and a0, t6, a1 # next digit in a0
	addi t5, t5, 1 #cnt ++
	ble t5, t4, start_num_print_loop # if cnt <= 8
	ret

error:
	exit 1
