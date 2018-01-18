.globl _start
_start:
lui  x30, 0x90000
addi x29, x0, 0x00000048 # H
sb   x29, 0 (x30)
#.rept 30
#nop
#.endr
addi x29, x0, 0x00000045 # E
sb   x29, 0 (x30)
#.rept 30
#nop
#.endr
addi x29, x0, 0x0000004C # L
sb   x29, 0 (x30)
#.rept 30
#nop
#.endr
#addi x29, x0, 0x0000004F # O
#sb   x29, 0 (x30)
#addi x29, x0, 0x00000020 # (space)
#sw   x29, 0 (x30)
#addi x29, x0, 0x00000057 # W
#sw   x29, 0 (x30)
#addi x29, x0, 0x0000004F # O
#sw   x29, 0 (x30)
#addi x29, x0, 0x00000052 # R
#sw   x29, 0 (x30)
#addi x29, x0, 0x0000004C # L
#sw   x29, 0 (x30)
#addi x29, x0, 0x00000044 # D
#sw   x29, 0 (x30)
