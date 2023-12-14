format binary

include 'T1\T1.inc'
  out r:1
  mov r:1, 13
  out r:1
  @@:
    dec r:1
    out r:1
    cmp r:1, 0
    jnz @b
  @@:
  mov r:1, 13
  out r:1
  hlt
endprog