macro ASCIIConvert MyNum&{
	MyNum = (MyNum and 0f0h) shr 4 + (MyNum and 0fh) shl 8	
	if (MyNum and 0fh) > 9
		MyNum = MyNum + 37h
	else
		MyNum = MyNum or 30h
	end if
	if (MyNum shr 8) and 0fh > 9
		MyNum = MyNum + 3700h
	else
		MyNum = MyNum or 3000h
	end if
}

macro d_b [val]{
local numbuf
	numbuf = val
	ASCIIConvert numbuf
	dw numbuf
	db 0Ah
}

macro db [val]{
local isone
	isone = 1
	match (len) dup(vals), val\{
		i = len
		while i > 0
			d_b vals
			i = i - 1
		end while
		isone = 0
		rept 0 \{
	\}
	match len dup(vals), val\{
		i = len
		while i > 0
			d_b vals
			i = i - 1
		end while
		isone = 0
	\}
	if isone = 1
	local thisval
		d_b val
	end if
}

struc db [val]{
	common
	.:
	db val
}

L fix 3

macro endprog{
	db (256-$/L) dup (0)
}

macro entry lbl*{
	mov r:0, lbl
	jmp r:0
}