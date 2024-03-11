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
	addi t1, zero, 10 # 10 = Enter
	beq a0, t1, end
	printch
	addi a0, a0, 1
	printch
	beq zero, zero, main
	
end:
	exit 1