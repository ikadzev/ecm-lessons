.include "funcs.asm"

main:
	li	t0, 1
	beq	a0, t0, start_len
	pstr	"Wrong arguments"
	exit 	1
start_len:
	lw 	a0, 0(a1)
	pstr	"Input: "
	prstr	a0
	mv 	s0, a0
	li	a0, 10
	printch
	mv	a0, s0
	call 	open
	mv 	s0, a0
	call	find_len
	pstr	"Length: "
	sys	1
	mv	a0, s0
	call 	close
	exit 	0
