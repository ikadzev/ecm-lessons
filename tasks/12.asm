.include "funcs.asm"

main:
	li t0, 1
	beq a0, t0, start
	pstr "Wrong args"
	exit 1
	
start:
	lw a0, 0(a1)
	call open
	mv s0, a0
	call find_len
	mv a1, a0
	mv a0, s0
	call load
	call cntln
	mv s1, a0
	sys 1
	mv a0, s1
	call close
	exit 0
	