macro endprog{
	db (65536-$) dup (0)
}

macro entry lbl*{
	jmp lbl
}