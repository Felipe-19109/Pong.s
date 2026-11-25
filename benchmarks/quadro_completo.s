# Mede o redesenho completo da tela (875 LEDs em RAM).
.data
.align 2
estado: .word 17, 12, -1, 1, 10, 0, 1
test_leds: .zero 3500
.text
main:
li sp, 0x7ffffff0
la a0, estado
la a1, test_leds
jal ra, desenhar
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

# a0 = estado, a1 = base dos LEDs. Redesenha uma tela completa
# (usado no inicio de cada partida).
desenhar:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    mv s0, a0
    mv s1, a1
    mv t0, s1
    li t1, 875
apagar:
    sw zero, 0(t0)
    addi t0, t0, 4
    addi t1, t1, -1
    bnez t1, apagar
    li s2, 0
bordas_horizontais:
    mv a0, s2
    li a1, 0
    li a2, 0x202060
    mv a3, s1
    jal ra, pixel
    mv a0, s2
    li a1, 24
    li a2, 0x202060
    mv a3, s1
    jal ra, pixel
    addi s2, s2, 1
    li t0, 35
    blt s2, t0, bordas_horizontais
    li s2, 1
borda_direita:
    li a0, 34
    mv a1, s2
    li a2, 0x202060
    mv a3, s1
    jal ra, pixel
    addi s2, s2, 1
    li t0, 24
    blt s2, t0, borda_direita
    mv a0, s0
    mv a1, s1
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    j desenhar_moveis

# a0 = estado, a1 = LEDs. Pinta (desenhar_moveis) ou apaga (apagar_moveis)
# apenas a raquete e a bola, sem limpar a tela inteira.
apagar_moveis:
    li a2, 0
    j pintar_moveis
desenhar_moveis:
    li a2, 1
pintar_moveis:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    mv s0, a0
    mv s1, a1
    mv s4, a2
    lw s2, 16(s0)
    addi s3, s2, 5
pintar_raquete:
    li a0, 1
    mv a1, s2
    li a2, 0
    beqz s4, cor_raquete_pronta
    li a2, 0x00c000
cor_raquete_pronta:
    mv a3, s1
    jal ra, pixel
    addi s2, s2, 1
    blt s2, s3, pintar_raquete
    lw a0, 0(s0)
    lw a1, 4(s0)
    li a2, 0
    beqz s4, pintar_bola
    li a2, 0xffff00
    lw t0, 24(s0)
    bnez t0, pintar_bola
    li a2, 0xff00ff
pintar_bola:
    mv a3, s1
    jal ra, pixel
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    ret
