
macro MAS rec*, src*{
local operands, srcbuf, recbuf
	operands = 0
	srcbuf equ
	match r:num, rec\{
		recbuf equ num
	\}
	match r:num, src\{
		srcbuf equ num
	\}
	if srcbuf eq a
		operands = recbuf
	else if srcbuf eq
		operands = recbuf or 11000000b
	else
		operands = (srcbuf shl 3) or recbuf or 10000000b
	end if
	db operands
	if srcbuf eq
		db src
	end if	
}

macro mov arg1*, arg2*{
	db 02h
	MAS arg1, arg2
}

macro add arg1*, arg2*{
	db 03h
	match reg:num, arg2\{
		MAS arg2, arg1
		rept 0\{
	\}
	rept 1\{
		MAS arg1, arg2
	\}
}

macro sub arg1*, arg2*{
	db 04
	match reg:num, arg2\{
		MAS arg2, arg1
		rept 0\{
	\}
	rept 1\{
		MAS arg1, arg2
	\}
}

macro inc {
	db 85h
}

macro dec {
	db 86h
}

macro hlt {
	db 0ffh
}

macro nop{
	db 00
}

macro lda const*{
local constbuf
	db 01h
	db const
}

macro jmp reg*{
	db 07h
	match r:num, reg\{
		if num eq a
			db 0
		else
			db num or 11000000b
		end if
	\}
}

macro jfz flag*, reg*{
local operands
	db 08h
	operands = 0
	match r:num, reg\{
		operands = num
	\}
	match r:num, flag\{
		if num eq a
			db operands
		else
			db operands or (num shl 3) or 11000000b
		end if
	\}
}

macro in reg1*, reg2*{
local operands
	operands = 0
	match reg:num, reg1\{
		operands = num
	\}
	match [reg:num], reg2\{
		operands = operands or (num shl 3)
	\}
	db 05h
	db operands
}

macro out reg1*, reg2*{
local operands
	operands = 0
	match reg:num, reg2\{
		operands = num
	\}
	match [reg:num], reg1\{
		operands = operands or (num shl 3)
	\}
	db 06h
	db operands
}