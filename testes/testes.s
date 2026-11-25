# Teste independente: estado inicial (7 palavras), botoes, estado esperado (7).
# A rotina passo abaixo e uma copia da rotina de pong.s.
.data
.align 2
casos:
# 1. movimento
.word 17, 12, -1, 1, 10, 0, 1, 0, 16, 13, -1, 1, 10, 0, 1
# 2. parede superior
.word 17, 1, 1, -1, 10, 0, 1, 0, 18, 2, 1, 1, 10, 0, 1
# 3. parede inferior
.word 17, 23, 1, 1, 10, 0, 1, 0, 18, 22, 1, -1, 10, 0, 1
# 4. parede direita
.word 33, 12, 1, 1, 10, 0, 1, 0, 32, 13, -1, 1, 10, 0, 1
# 5. defesa central
.word 2, 11, -1, 1, 10, 0, 1, 0, 2, 12, 1, 1, 10, 1, 1
# 6. defesa ponta superior
.word 2, 9, -1, 1, 10, 2, 1, 0, 2, 10, 1, 1, 10, 3, 1
# 7. defesa ponta inferior
.word 2, 13, -1, 1, 10, 0, 1, 0, 2, 14, 1, 1, 10, 1, 1
# 8. passa acima da raquete
.word 2, 8, -1, 1, 10, 0, 1, 0, 1, 9, -1, 1, 10, 0, 1
# 9. passa abaixo da raquete
.word 2, 14, -1, 1, 10, 0, 1, 0, 1, 15, -1, 1, 10, 0, 1
# 10. perda na esquerda
.word 1, 8, -1, 1, 10, 3, 1, 0, 0, 9, -1, 1, 10, 3, 0
# 11. limite superior raquete
.word 17, 12, 1, 1, 1, 0, 1, 1, 18, 13, 1, 1, 1, 0, 1
# 12. limite inferior raquete
.word 17, 12, 1, 1, 19, 0, 1, 2, 18, 13, 1, 1, 19, 0, 1
# 13. mover para cima
.word 17, 12, 1, 1, 10, 0, 1, 1, 18, 13, 1, 1, 9, 0, 1
# 14. mover para baixo
.word 17, 12, 1, 1, 10, 0, 1, 2, 18, 13, 1, 1, 11, 0, 1
# 15. botoes simultaneos
.word 17, 12, 1, 1, 10, 0, 1, 3, 18, 13, 1, 1, 10, 0, 1
# 16. canto superior direito
.word 33, 1, 1, -1, 10, 0, 1, 0, 32, 2, -1, 1, 10, 0, 1
# 17. estado encerrado
.word 0, 9, -1, 1, 10, 3, 0, 2, 0, 9, -1, 1, 10, 3, 0
# 18. defesa apos mover raquete
.word 2, 8, -1, 1, 10, 0, 1, 1, 2, 9, 1, 1, 9, 1, 1
ok: .string "18 testes de movimento e colisao aprovados.\n"
falha: .string "FALHA no caso: "
.text
main:
li sp, 0x7ffffff0
la s0, casos
li s1, 18
li s2, 1
proximo:
mv a0, s0
lw a1, 28(s0)
jal ra, passo
li t0, 0
conferir:
add t1, s0, t0
lw t2, 0(t1)
lw t3, 32(t1)
bne t2, t3, erro
addi t0, t0, 4
li t1, 28
blt t0, t1, conferir
addi s0, s0, 60
addi s2, s2, 1
addi s1, s1, -1
bnez s1, proximo
la a0, ok
li a7, 4
ecall
j sair
erro:
la a0, falha
li a7, 4
ecall
mv a0, s2
li a7, 1
ecall
sair:
li a7, 10
ecall

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

