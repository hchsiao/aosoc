.globl _start
_start:
lui  x30, 0x21000
addi x29, x0, 0x48 # H
addi x28, x0, 0x45 # E
addi x27, x0, 0x4C # L
addi x26, x0, 0x4F # O
addi x25, x0, 0x20 # space
addi x24, x0, 0x57 # W
addi x23, x0, 0x52 # R
addi x22, x0, 0x44 # D
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
b1:
j    b1
