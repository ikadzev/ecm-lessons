.include 	"funcs.asm"

main:
	call 	read_dec
	mv 	s0, a0
	call 	read_dec
	mv 	a1, a0
	mv 	a0, s0
	call 	division
	call	print_dec
	exit	0
	
division:
	push s0
	push s1
	li	t0, 1		#mask
	li	t1, 32		#cnt
	li	s0, 0		#current_number
	li	s1, 0		#output_number
zero_loop:
	addi	t1, t1, -1
	sll	t2, t0, t1	#shifted mask
	and	t3, a0, t2	#digit
	srl	t3, t3, t1
	bnez	t3, start_division
	beqz	t1, print_zero
	j	zero_loop
start_division:
	slli	s0, s0, 1
	add 	s0, s0, t3
	slli 	s1, s1, 1
	blt	s0, a1, after_sub
	addi 	s1, s1, 1
	sub	s0, s0, a1
after_sub:
	beqz	t1, end_division
	addi	t1, t1, -1
	sll	t2, t0, t1
	and	t3, a0, t2
	srl	t3, t3, t1
	j	start_division
end_division:
	mv a0, s1
	pop s1
	pop s0
	ret
print_zero:
	li	a0, 0
	ret