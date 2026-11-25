# Compara preparacao isolada e chamada de pixel.
.text
main:
li sp, 0x7ffffff0
li a0, 17
li a1, 12
li a2, 0xffff00
li a3, 0x10010000
li a7, 10
ecall
