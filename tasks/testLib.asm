.include "funcs.asm"

.macro FUNC %func, %str
.data
func_name: .asciz %str
.text
	la s4, func_name
	pstr "Testing function "
	prstr s4
	pstrln "..."
	la s0, %func
	li s1, 0 #passed
	li s2, 0 #failed
.end_macro

.macro OK %int, %str, %chr
.data
strr: .asciz %str
.text
	la s5, strr
	mv  a0, s5
	li a1, %chr
	jalr s0
	sub a0, a0, s5
	li t0, %int
	beq a0, t0, ok_fail
# Test falied: strchr(“abcde”, 'a') results in OK(0), expected OK(2)
	addi s2, s2, 1
	pstr "Test falied: "
	prstr s4
	pstr "("
	prstr s5
	pstr ", \'"
	pch %chr
	pstr "\') results in OK("
	sys 1
	pstr "), expected OK("
	pint %int
	pstrln ")"
	j ok_end
ok_fail:
	addi s1, s1, 1
ok_end:
.end_macro

.macro NONE %str, %chr
.data
strr: .asciz %str
.text
	la s5, strr
	mv a0, s5
	li a1, %chr
	jalr s0
	sub a0, a0, s5
	beqz a0, none_fail
# Test falied: strchr(“abcde”, 'a') results in OK(0), expected NONE
	addi s2, s2, 1
	pstr "Test falied: "
	prstr s4
	pstr "("
	prstr s5
	pstr ", \'"
	pch %chr
	pstr "\') results in OK("
	sys 1
	pstrln "), expected NONE"
	j none_end
none_fail:
	addi s1, s1, 1
none_end:
.end_macro

.macro DONE
	pstr "Passed: "
	mv a0, s1
	sys 1
	pstr ", failed: "
	mv a0, s2
	sys 1
	pstrln ""
.end_macro
