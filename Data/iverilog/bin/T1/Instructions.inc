NOP_I equ 10000b
HLT_I equ 10001b
ONE_BYTE equ 00b
TWO_BYTE equ 01b
THREE_BYTE equ 11b
FIRST equ 0
	MOV_I equ FIRST
	MOV_I_R_R equ 0x00
	MOV_I_R_RM equ 0x01
	MOV_I_RM_R equ 0x02
	ADD_I_R_R = 0x03
	ADD_I_R_RM = 0x04
	ADD_I_RM_R = 0x05 
	SUB_I_R_R = 0x06
	SUB_I_R_RM = 0x07
	SUB_I_RM_R = 0x08 
	CMP_I_R_R = 0x09
	CMP_I_R_RM = 0x0A
	CMP_I_RM_R = 0x0B
	AND_I_R_R = 0x0C
	AND_I_R_RM = 0x0D
	AND_I_RM_R = 0x0E
	OR_I_R_R = 0x0D
	OR_I_R_RM = 0x0F
	OR_I_RM_R = 0x10
	XOR_I_R_R = 0x11
	XOR_I_R_RM = 0x12
	XOR_I_RM_R = 0x13
	SHR_I_R_R = 0x14
	SHR_I_R_RM = 0x15
	SHR_I_RM_R = 0x16
	SHL_I_R_R = 0x17
	SHL_I_R_RM = 0x18
	SHL_I_RM_R = 0x19
MOV_I_R_C EQU 000b
MOV_I_R_CM equ 110b
MOV_I_CM_R equ 111b

; macro INS_R_R instr*, op1*, op2*{
; 	db INS_R_R + op1 shl 5
; 	db instr + op2 shl 5
; }

macro nop{
	db NOP_I
}

macro hlt{
	db HLT_I
}

macro stfz{
	db STFZ
}

macro LDFZ{
	db LDFZ
}

macro hlt{
	db HLT_I
}

macro INS_C arg1*, instr{
local IsReg
	IsReg = 0
	match [reg:num], arg1\{
		IsReg = 1
		db instr#\_RM + ONE_BYTE shl 3 + num shl 5
		rept 0\{
	\}
	match reg:num, arg1\{
		IsReg = 1
		db instr#\_R + ONE_BYTE shl 3 + num shl 5
	\}
	if IsReg = 0
		match [const], arg1\{
			IsReg = 1
			db instr#\_CM + THREE_BYTE shl 3 + num shl 5
			dw const 
		\}
		if IsReg = 0
			db instr#\_C + THREE_BYTE shl 3 + num shl 5
			dw arg1 
		end if
	end if
}

macro out arg1*{
	INS_C arg1, OUT
}

macro jmp arg1*{
	INS_C arg1, JMP
}

macro in arg1*{
	INS_C arg1, IN
}

macro INS_R_R instr, arg1*, arg2*{
local test1
	test1 = 0
	match [reg1:num1], arg1\{
		test1 = 1
		match reg2:num2, arg2\\{
			db instr + (TWO_BYTE shl 3) + (num1 shl 5)
			db instr#\_RM_R + num2 shl 5
		\\}
		rept 0\{
	\}
	match [const], arg1\{
		test1 = 1
		match reg2:num2, arg2\\{
			db instr#\_CM_R + (THREE_BYTE shl 3) + (num2 shl 5)
			dw const
		\\}
	\}
	if test1 = 0
		match reg1:num1, arg1\{
			local default
			default = 1
			match [reg2:num2], arg2\\{
				default = 0
				db instr + (TWO_BYTE shl 3) + (num1 shl 5)
				db instr#\_R_RM + num2 shl 5
				rept 0\\{
			\\}
			match reg2:num2, arg2\\{
				default = 0
				db instr + (TWO_BYTE shl 3) + (num1 shl 5)
				db instr#\_R_R + num2 shl 5
			\\}
			if default = 1
				match [const], arg2\\{
					default = 0
					db instr#\_R_CM + (THREE_BYTE shl 3) + (num1 shl 5)
					dw const
				\\}
				if default = 1
					db instr#\_R_C + (THREE_BYTE shl 3) + (num1 shl 5)
					dw arg2
				end if
			end if
		\}
	end if
}

macro mov arg1*, arg2*{
	INS_R_R MOV_I, arg1, arg2
}

macro add arg1*, arg2*{
	INS_R_R ADD, arg1, arg2
}

macro sub arg1*, arg2*{
	INS_R_R SUB, arg1, arg2
}

macro cmp arg1*, arg2*{
	INS_R_R CMP, arg1, arg2
}

macro jz arg1*{
	INS_R_R JF, f:100b, arg1
}

macro jnz arg1*{
	INS_R_R JF, f:000b, arg1
}

macro ja arg1*{
	INS_R_R JF, f:101b, arg1
}

macro jna arg1*{
	INS_R_R JF, f:001b, arg1
}

macro inc arg{
	match reg:num, arg\{
		db INC_I + num shl 5
	\}
}

macro dec arg{
	match reg:num, arg\{
		db DEC_I + num shl 5
	\}
}

; macro in reg1*, reg2*{
; local operands
; 	operands = 0
; 	match reg:num, reg1\{
; 		operands = num
; 	\}
; 	match [reg:num], reg2\{
; 		operands = operands or (num shl 3)
; 	\}
; 	db 05h
; 	db operands
; }

; macro out reg1*, reg2*{
; local operands
; 	operands = 0
; 	match reg:num, reg2\{
; 		operands = num
; 	\}
; 	match [reg:num], reg1\{
; 		operands = operands or (num shl 3)
; 	\}
; 	db 06h
; 	db operands
; }

; macro hlt {
; 	db 0ffh
; }

; macro nop{
; 	db 00
; }