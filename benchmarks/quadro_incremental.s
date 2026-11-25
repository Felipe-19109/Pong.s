# Mede apagar_moveis + passo + desenhar_moveis, o trabalho de um quadro do jogo.
.data
.align 2
estado: .word 17, 12, -1, 1, 10, 0, 1
test_leds: .zero 3500
.text
main:
li sp, 0x7ffffff0
la s0, estado
la s1, test_leds
mv a0, s0
mv a1, s1
jal ra, apagar_moveis
mv a0, s0
li a1, 0
jal ra, passo
mv a0, s0
mv a1, s1
jal ra, desenhar_moveis
li a7, 10
ecall

# a0 = estado; a1 = botoes (bit 0 cima, bit 1 baixo).
# Atualiza um quadro. Nao usa I/O nem altera registradores s.
passo:
    lw t0, 24(a0)
    beqz t0, passo_fim
    lw t0, 16(a0)
    andi a1, a1, 3
    li t1, 1
    beq a1, t1, subir
    li t1, 2
    beq a1, t1, descer
    j raquete_pronta
subir:
    li t1, 1
    ble t0, t1, raquete_pronta
    addi t0, t0, -1
    j raquete_pronta
descer:
    li t1, 19
    bge t0, t1, raquete_pronta
    addi t0, t0, 1
raquete_pronta:
    sw t0, 16(a0)
    lw t1, 0(a0)
    lw t2, 4(a0)
    lw t3, 8(a0)
    lw t4, 12(a0)
    add t1, t1, t3
    add t2, t2, t4
    bgtz t2, testar_baixo
    li t2, 2
    li t4, 1
testar_baixo:
    li t5, 24
    blt t2, t5, testar_direita
    li t2, 22
    li t4, -1
testar_direita:
    li t5, 34
    blt t1, t5, testar_raquete
    li t1, 32
    li t3, -1
testar_raquete:
    bgez t3, guardar_bola
    li t5, 1
    bne t1, t5, testar_perda
    blt t2, t0, testar_perda
    addi t5, t0, 4
    bgt t2, t5, testar_perda
    li t1, 2
    li t3, 1
    lw t5, 20(a0)
    addi t5, t5, 1
    sw t5, 20(a0)
    j guardar_bola
testar_perda:
    bgtz t1, guardar_bola
    li t1, 0
    sw zero, 24(a0)
guardar_bola:
    sw t1, 0(a0)
    sw t2, 4(a0)
    sw t3, 8(a0)
    sw t4, 12(a0)
passo_fim:
    ret

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
