.globl _start
_start:
b1:
lui  x30, 0x21000
addi x29, x0, 0x00000048 # H
addi x28, x0, 0x00000069 # E
addi x27, x0, 0x00000076 # L
addi x26, x0, 0x00000079 # O
addi x25, x0, 0x00000032 # space
addi x24, x0, 0x00000087 # W
addi x23, x0, 0x00000082 # R
addi x22, x0, 0x00000068 # D
sw   x29, 0 (x30)        # H
sw   x28, 0 (x30)        # E
sw   x27, 0 (x30)        # L
sw   x27, 0 (x30)        # L
sw   x26, 0 (x30)        # O
sw   x25, 0 (x30)        #
sw   x24, 0 (x30)        # W
sw   x26, 0 (x30)        # O
sw   x23, 0 (x30)        # R
sw   x27, 0 (x30)        # L
sw   x22, 0 (x30)        # D
j    b1
