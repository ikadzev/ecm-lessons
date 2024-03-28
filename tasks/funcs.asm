j random_name_for_jump
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
	slti %temp, %num, '0' # not a number
	bnez %temp, error
	li %temp, '0'
	sub %num, %num, %temp # now dec in a0
	slti %temp, %num, 10 # if 0-9
	bnez %temp, end_check
	slti %temp, %num, 17 # NaN
	bnez %temp, error
	addi %num, %num, -17 # now HEX in a0
	slti %temp, %num, 6 # if A-F
	bnez %temp, end_hex_check
	slti %temp, %num, 32 # NaN
	bnez %temp, error
	addi %num, %num, -32 # now hex in a0
	slti %temp, %num, 6 # if a-f
	bnez %temp, end_hex_check
	j error # not a number
end_hex_check:
	addi %num, %num, 10
end_check:
.end_macro

.macro push %r
	addi sp, sp, -4
	sw %r, 0(sp)
.end_macro

.macro pop %r
	lw %r, 0(sp)
	addi sp, sp, 4
.end_macro

.macro beqi %reg, %imm, %branch
	li t0, %imm
	beq %reg, t0, %branch
.end_macro

error:
	exit 1
	
random_name_for_jump:
