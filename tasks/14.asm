.include "funcs.asm"

main:
	li t0, 2
	beq a0, t0, start
	
start:
	lw a0, 4(a1)
	lw s1, 0(a1)
	call open
	mv s0, a0
	call find_len
	mv s2, a0
	mv a1, a0
	mv a0, s0
	call load
	mv a1, s2
	mv a2, s1
	call grep
	call print_lines
	mv a0, s0
	call close
	exit 0
	
print_lines: # a0 - list[0-term str], a1 - length
	push ra
	push s0
	push s1
	push s2
	mv s0, a0
	mv s1, a1
pln_loop:
	beqz s1, pln_end
	lw s2, 0(s0)
	prstr s2
	pstrln ""
	addi s0, s0, 4
	addi s1, s1, -1
	j pln_loop
pln_end:
	pop s2
	pop s1
	pop s0
	pop ra
	ret
	
grep:# a0 - file, a1 - flen, a2 - match
	push ra
	push s0
	push s1
	push s2
	push s3
	push s4
	push s5
	mv s0, a0 # file
	mv s1, a2 # match
	mv a0, a1
	sys 9
	mv s2, a0 # adress for matched lines (list of 0-terminated lines)
	li s4, 0 # len(s2)
	mv s5, s2 #start
grep_line_loop:
	mv s3, s0 # start of line
grep_str_loop:
	lb t0, 0(s0)
	beqz t0, grep_end
	li t1, '\n'
	beq t0, t1, grep_line_end
	lb t1, 0(s1)
	beq t0, t1, grep_match
	addi s0, s0, 1
	j grep_str_loop
grep_match:
	mv a0, s0
	mv a1, s1
	call match
	bnez a0, grep_match_true
	addi s0, s0, 1
	j grep_str_loop
grep_match_true:
	sw s3, 0(s2)
	addi s2, s2, 4
	addi s4, s4, 1
	mv a0, s0
	li a1, '\n'
	call strchr
	beqz a0, grep_end
	sb zero, 0(a0)
	mv s0, a0
grep_line_end:
	addi s0, s0, 1
	j grep_line_loop
grep_end:
	mv a0, s5
	mv a1, s4
	pop s5
	pop s4
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret


match: # a0 - address of match, a1 - matching line
	lb t0, 0(a1)
	beqz t0, match_true
	lb t1, 0(a0)
	beqz t1, match_false
	li t2, '\n'
	beq t1, t2, match_false
	bne t0, t1, match_false
	addi a1, a1, 1
	addi a0, a0, 1
	j match
match_false:
	li a0, 0
	ret
match_true:
	li a0, 1
	ret