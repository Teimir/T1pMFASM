macro endprog{
	db (256-$) dup (0)
}

macro entry lbl*{
	mov r:6, lbl
	jmp r:6
}