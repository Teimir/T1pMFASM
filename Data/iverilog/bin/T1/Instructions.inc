SPECIAL equ 10b
	NOP_I equ 000b + SPECIAL shl 3
	HLT_I equ 001b + SPECIAL shl 3
	LDFZ_I equ 010b + SPECIAL shl 3
	STFZ_I equ 011b + SPECIAL shl 3
ONE_BYTE equ 00b
	OUT_I_R = 000b
	OUT_I_RM = 0001b
	JMP_I_R = 100b
	JMP_I_RM =  101b
	INC_I_R = 010b
	DEC_I_R = 011b
	IN_I_R = 110b
	IN_I_RM = 111b
TWO_BYTE equ 01b
	FIRST equ 0
		MOV_I equ FIRST
		MOV_I_R_R equ 0x00
		MOV_I_R_RM equ 0x01
		MOV_I_RM_R equ 0x02
		ADD_I equ FIRST
		ADD_I_R_R equ 0x03
		ADD_I_R_RM equ 0x04
		ADD_I_RM_R equ 0x05 
		SUB_I equ FIRST
		SUB_I_R_R equ 0x06
		SUB_I_R_RM equ 0x07
		SUB_I_RM_R equ 0x08 
		CMP_I equ FIRST
		CMP_I_R_R equ 0x09
		CMP_I_R_RM equ 0x0A
		CMP_I_RM_R equ 0x0B
		AND_I equ FIRST
		AND_I_R_R equ 0x0C
		AND_I_R_RM equ 0x0D
		AND_I_RM_R equ 0x0E
		OR_I equ FIRST
		OR_I_R_R equ 0x0D
		OR_I_R_RM equ 0x0F
		OR_I_RM_R equ 0x10
		XOR_I equ FIRST
		XOR_I_R_R equ 0x11
		XOR_I_R_RM equ 0x12
		XOR_I_RM_R equ 0x13
		SHR_I equ FIRST
		SHR_I_R_R equ 0x14
		SHR_I_R_RM equ 0x15
		SHR_I_RM_R equ 0x16
		SHL_I equ FIRST
		SHL_I_R_R equ 0x17
		SHL_I_R_RM equ 0x18
		SHL_I_RM_R equ 0x19
	JF_R = 100b
	JF_RM = 101b
THREE_BYTE equ 11b
	MOV_I_R_C EQU 000b
	MOV_I_R_CM equ 110b
	MOV_I_CM_R equ 111b
	ADD_I_R_C equ 001b
	SUB_I_R_C equ 010b
	CMP_I_R_C equ 011b
	JF_I_C equ 100b
	JF_I_CM equ 101b

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
	INS_C arg1, OUT_I
}

macro jmp arg1*{
	INS_C arg1, JMP_I
}

macro in arg1*{
	INS_C arg1, IN_I
}

macro inc arg1{
	INS_C arg1, INC_I
}

macro dec arg{
	INS_C arg1, DEC_I
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
	INS_R_R ADD_I, arg1, arg2
}

macro sub arg1*, arg2*{
	INS_R_R SUB_I, arg1, arg2
}

macro cmp arg1*, arg2*{
	INS_R_R CMP_I, arg1, arg2
}

macro and arg1*, arg2*{
	INS_R_R AND_I, arg1, arg2
}

macro or arg1*, arg2*{
	INS_R_R OR_I, arg1, arg2
}

macro xor arg1*, arg2*{
	INS_R_R XOR_I, arg1, arg2
}

macro shr arg1*, arg2*{
	INS_R_R SHR_I, arg1, arg2
}

macro shl arg1*, arg2*{
	INS_R_R SHL_I, arg1, arg2
}

macro JIF_M arg1, flags{
local IsReg
	IsReg = 0
	match [reg:num], arg1\{
		IsReg = 1
		db JF_RM + TWO_BYTE shl 3 + 100b shl 5
		db num shl 5
		rept 0\{
	\}
	match reg:num, arg1\{
		IsReg = 1
		db JF_R + TWO_BYTE shl 3 + 100b shl 5
		db num shl 5
	\}
	if IsReg = 0
		match [const], arg1\{
			IsReg = 1
			db JF_I_CM + THREE_BYTE shl 3 + 100b shl 5
			dw const 
		\}
		if IsReg = 0
			db JF_I_C + THREE_BYTE shl 3 + 100b shl 5
			dw arg1 
		end if
	end if
}

macro jz arg1*{
	JIF_M arg1, 100b
}

macro jnz arg1*{
	JIF_M arg1, 000b
}

macro ja arg1*{
	JIF_M arg1, 101b
}

macro jna arg1*{
	JIF_M arg1, 001b
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