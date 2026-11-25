# Mede um passo sem colisao e sem botoes.
.data
.align 2
estado: .word 17, 12, -1, 1, 10, 0, 1
.text
main:
li sp, 0x7ffffff0
la a0, estado
li a1, 0
jal ra, passo
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
