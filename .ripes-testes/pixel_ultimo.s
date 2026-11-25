# Pong de 1 jogador - Ripes, RV32I (sem M/C)
# I/O: LED Matrix 35x25 primeiro; D-Pad depois.
# Cima/baixo movem a raquete. Uma seta inicia ou reinicia.
.equ LED_BASE, 0xf0000000
.equ DPAD_BASE, 0xf0000dac
.equ DELAY, 1000


.data
.align 2
test_leds: .zero 3500
test_dpad: .word 0, 0, 0, 0
estado: .word 17, 12, -1, 1, 10, 0, 1
inicio: .string "PONG RV32I - aperte uma seta para comecar\nCima/baixo movem a raquete.\n"
pontos: .string "Pontos: "
fim: .string "GAME OVER! Pontos: "
novamente: .string "\nSolte os botoes e aperte uma seta para reiniciar.\n"
nova_linha: .string "\n"

.text
main:
li sp, 0x7ffffff0
li s0, 101
li s1, 102
li s2, 103
li s3, 104
li s4, 105
li s5, 106
li s6, 107
li s7, 108
li s8, 109
li s9, 110
li s10, 111
li s11, 112

li a0, 34
li a1, 24
li a2, 0xabcdef
la a3, test_leds
jal ra, pixel
la t0, test_leds
li t1, 3496
add t1, t0, t1
lw a0, 0(t1)
la t0, test_leds
li t1, 3492
add t1, t0, t1
lw a1, 0(t1)
li a7, 10
ecall

# a0 = estado. Restaura uma partida com zero pontos.
iniciar_estado:
    li t0, 17
    sw t0, 0(a0)
    li t0, 12
    sw t0, 4(a0)
    li t0, -1
    sw t0, 8(a0)
    li t0, 1
    sw t0, 12(a0)
    sw t0, 24(a0)
    li t0, 10
    sw t0, 16(a0)
    sw zero, 20(a0)
    ret

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

# a0 = base do D-Pad; devolve a0 = OR dos quatro botoes.
ler_botoes:
    lw t0, 0(a0)
    lw t1, 4(a0)
    or t0, t0, t1
    lw t1, 8(a0)
    or t0, t0, t1
    lw t1, 12(a0)
    or a0, t0, t1
    ret

# a0 = base do D-Pad. Exige soltar antes de um novo comando.
esperar_inicio:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
soltar:
    mv a0, s0
    jal ra, ler_botoes
    bnez a0, soltar
pressionar:
    mv a0, s0
    jal ra, ler_botoes
    beqz a0, pressionar
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# a0 = base do D-Pad; retorna a0 = ultimo comando durante DELAY.
# Guarda toques curtos; cima e baixo simultaneos nao movem a raquete.
esperar_controle:
    mv t0, a0
    li a0, 0
    li t1, DELAY
controle_loop:
    lw t2, 0(t0)
    lw t3, 4(t0)
    andi t2, t2, 1
    andi t3, t3, 1
    slli t3, t3, 1
    or t2, t2, t3
    beqz t2, controle_proximo
    mv a0, t2
controle_proximo:
    addi t1, t1, -1
    bnez t1, controle_loop
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

