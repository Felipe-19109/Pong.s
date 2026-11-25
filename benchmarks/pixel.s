# Mede uma chamada de pixel (endereco = base + (y*35 + x)*4).
.text
main:
li sp, 0x7ffffff0
li a0, 17
li a1, 12
li a2, 0xffff00
li a3, 0x10010000
jal ra, pixel
li a7, 10
ecall

# a0 = x, a1 = y, a2 = cor, a3 = base dos LEDs.
pixel:
    slli t0, a1, 5
    slli t1, a1, 1
    add t0, t0, t1
    add t0, t0, a1
    add t0, t0, a0
    slli t0, t0, 2
    add t0, a3, t0
    sw a2, 0(t0)
    ret
