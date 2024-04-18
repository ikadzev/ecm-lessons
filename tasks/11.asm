.include "funcs.asm"

main:
	li	t0, 1
	beq	a0, t0, start_len
	exit 	1
start_len:
	lw 	a0, 0(a1)
	pstr	"input: "
	prstr	a0
	mv 	s0, a0
	li	a0, 10
	printch
	mv	a0, s0
	call 	open
	mv 	s0, a0
	call	find_len
	pstr	"length: "
	sys	1
	mv	a0, s0
	call 	close
	exit 	0
	
find_len:
	push	s0
	push	s1
	push	s2
	li 	t0, -1 # error_code
	mv 	s0, a0
	li 	a1, 0
	li	a2, 2
	sys	62
	beq	a0, t0, len_error
	mv	s1, a0
	mv	a1, a0
	li	a2, 0
	sys	62
	mv a0, s1
	pop 	s2
	pop 	s1
	pop 	s0
	ret
len_error:
	pstr "Failed finding lenght"
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