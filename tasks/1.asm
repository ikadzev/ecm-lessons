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