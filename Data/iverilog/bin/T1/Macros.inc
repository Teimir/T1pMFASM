macro endprog{
	db (65536-$) dup (0)
}

macro entry lbl*{
	mov r:6, lbl
	jmp r:6
}