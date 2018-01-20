.globl _start
_start:
b1:
lui  x30, 0x22000
addi x29, x0, 0x00000048 # H
sw   x29, 0 (x30)
j    b1
