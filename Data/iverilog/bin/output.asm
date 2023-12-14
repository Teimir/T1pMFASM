format binary

include 'T1\T1.inc'
	mov r:0, 13
	mov r:1, 1
	mov r:2, 0
	@@:
		add r:2, r:1
		mov r:3, r:2
		mov r:2, r:1
		mov r:1, r:3
		dec r:0
		out r:0
		jz @f
	jmp @b
	@@:
	hlt
endprog