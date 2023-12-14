OUT_R = 00h
OUT_RM = 01h
JMP_R = 02h
JMP_RM = 03h
INC_I = 04h
DEC_I = 05h
IN_R = 06h
IN_RM = 07h
ZOI = 08h
	NOP_I = (000b shl 5) + ZOI
	HLT_I = (001b shl 5) + ZOI
	STFZ = (010b shl 5) + ZOI
	LDFZ = (011b shl 5) + ZOI
INS_C = 09h
	OUT_C = (000b shl 5) + INS_C
	OUT_CM = (001b shl 5) + INS_C
	JMP_C = (010b shl 5) + INS_C
	JMP_CM = (011b shl 5) + INS_C
	IN_CM = (100b shl 5) + INS_C
INS_R_R = 0Ah
	MOV_R_R = 01h
	MOV_R_RM = 02h
	MOV_RM_R = 03h
	ADD_R_R = 04h
	ADD_R_RM = 05h
	ADD_RM_R = 06h
	SUB_R_R = 07h
	SUB_R_RM = 08h
	SUB_RM_R = 09h
	CMP_R_R = 0Ah
	CMP_R_RM = 0Bh
	CMP_RM_R = 0Ch
	JF_R_R = 0Dh
	JF_R_RM = 0Ah
MOV_R_C = 0Bh
MOV_R_CM = 0Ch
MOV_CM_R = 0Dh
ADD_R_C = 0Eh
ADD_R_CM = 0Fh
ADD_CM_R = 10h
SUB_R_C = 11h
SUB_R_CM = 12h
SUB_CM_R = 13h
CMP_R_C = 14h
CMP_R_CM = 15h
CMP_CM_R = 16h
JF_R_C = 17h
JF_R_CM = 18h

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
		db instr#\_RM + num shl 5
		rept 0\{
	\}
	match reg:num, arg1\{
		IsReg = 1
		db instr#\_R + num shl 5
	\}
	if IsReg = 0
		match [const], arg1\{
			IsReg = 1
			db instr#\_CM
			db const 
		\}
		if IsReg = 0
			db instr#\_C
			db arg1 
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
			db INS_R_R + num1 shl 5
			db instr#\_RM_R + num2 shl 5
		\\}
		rept 0\{
	\}
	match [const], arg1\{
		test1 = 1
		match reg2:num2, arg2\\{
			db instr#\_CM_R + num2 shl 5
			db const
		\\}
	\}
	if test1 = 0
		match reg1:num1, arg1\{
			local default
			default = 1
			match [reg2:num2], arg2\\{
				default = 0
				db INS_R_R + num1 shl 5
				db instr#\_R_RM + num2 shl 5
				rept 0\\{
			\\}
			match reg2:num2, arg2\\{
				default = 0
				db INS_R_R + num1 shl 5
				db instr#\_R_R + num2 shl 5
			\\}
			if default = 1
				match [const], arg2\\{
					default = 0
					db instr#\_R_CM + num1 shl 5
					db const
				\\}
				if default = 1
					db instr#\_R_C + num1 shl 5
					db arg2
				end if
			end if
		\}
	end if
}

macro mov arg1*, arg2*{
	INS_R_R MOV, arg1, arg2
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