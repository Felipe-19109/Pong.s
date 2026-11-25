# Mede uma espera com os quatro botoes soltos em RAM.
.equ DELAY, 3000
.data
.align 2
test_dpad: .zero 16
.text
main:
li sp, 0x7ffffff0
la a0, test_dpad
jal ra, esperar_controle
li a7, 10
ecall

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
