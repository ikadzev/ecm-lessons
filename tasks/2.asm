.include "funcs.asm"

main:
	readch
	li t1, 10 # 10 = Enter
	beq a0, t1, end
	printch
	addi a0, a0, 1
	printch
	j main
	
end:
	exit 1
