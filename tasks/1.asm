.include "funcs.asm"

main:
	readch
	slti t1 a0 '0'
	bne zero, t1, end
	slti t1 a0 ':'
	beq zero, t1, end
	li a0, '1'
	printch
	
end:
	exit 0
