# Clang 17.0.1 (Compiler Explorer, rv32-cclang1701)
# -O2 -march=rv32i -mabi=ilp32 -ffreestanding -g0 -fno-verbose-asm
# Fonte: c-reference/pong.c

main:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        sw      s1, 52(sp)
        sw      s2, 48(sp)
        sw      s3, 44(sp)
        sw      s4, 40(sp)
        sw      s5, 36(sp)
        sw      s6, 32(sp)
        sw      s7, 28(sp)
        sw      s8, 24(sp)
        sw      s9, 20(sp)
        sw      s10, 16(sp)
        sw      s11, 12(sp)
        li      a0, 875
        lui     a1, 983040
.LBB0_1:
        sw      zero, 0(a1)
        addi    a0, a0, -1
        addi    a1, a1, 4
        bnez    a0, .LBB0_1
        li      a0, 35
        lui     a1, 983040
        lui     a2, 514
        addi    a2, a2, 96
.LBB0_3:
        sw      a2, 0(a1)
        addi    a3, a1, 2047
        sw      a2, 1313(a3)
        addi    a0, a0, -1
        addi    a1, a1, 4
        bnez    a0, .LBB0_3
        lui     a0, 514
        addi    s2, a0, 96
        lui     s3, 983040
        sw      s2, 276(s3)
        sw      s2, 416(s3)
        sw      s2, 556(s3)
        sw      s2, 696(s3)
        sw      s2, 836(s3)
        sw      s2, 976(s3)
        sw      s2, 1116(s3)
        sw      s2, 1256(s3)
        sw      s2, 1396(s3)
        sw      s2, 1536(s3)
        sw      s2, 1676(s3)
        sw      s2, 1816(s3)
        sw      s2, 1956(s3)
        lui     s4, 983041
        sw      s2, -2000(s4)
        sw      s2, -1860(s4)
        sw      s2, -1720(s4)
        sw      s2, -1580(s4)
        sw      s2, -1440(s4)
        sw      s2, -1300(s4)
        sw      s2, -1160(s4)
        sw      s2, -1020(s4)
        sw      s2, -880(s4)
        sw      s2, -740(s4)
        lui     a0, 12
        sw      a0, 1404(s3)
        sw      a0, 1544(s3)
        sw      a0, 1684(s3)
        sw      a0, 1824(s3)
        sw      a0, 1964(s3)
        lui     a0, 4096
        addi    a0, a0, -256
        sw      a0, 4(sp)
        sw      a0, 1748(s3)
        lui     s7, 524288
        addi    s5, s7, -5
        lui     a0, 4080
        addi    a0, a0, 255
        sw      a0, 8(sp)
.LBB0_5:
        lw      a0, -596(s4)
        lw      a1, -592(s4)
        lw      a2, -588(s4)
        lw      a3, -584(s4)
        or      a0, a1, a0
        or      a2, a2, a3
        or      a0, a0, a2
        bnez    a0, .LBB0_5
.LBB0_6:
        lw      a0, -596(s4)
        lw      a1, -592(s4)
        lw      a2, -588(s4)
        lw      a3, -584(s4)
        or      a0, a1, a0
        or      a2, a2, a3
        or      a0, a0, a2
        beqz    a0, .LBB0_6
        li      a0, 875
        lui     a1, 983040
.LBB0_8:
        sw      zero, 0(a1)
        addi    a0, a0, -1
        addi    a1, a1, 4
        bnez    a0, .LBB0_8
        li      a0, 35
        lui     a1, 983040
.LBB0_10:
        sw      s2, 0(a1)
        addi    a2, a1, 2047
        sw      s2, 1313(a2)
        addi    a0, a0, -1
        addi    a1, a1, 4
        bnez    a0, .LBB0_10
        sw      s2, 276(s3)
        sw      s2, 416(s3)
        sw      s2, 556(s3)
        sw      s2, 696(s3)
        sw      s2, 836(s3)
        sw      s2, 976(s3)
        sw      s2, 1116(s3)
        sw      s2, 1256(s3)
        sw      s2, 1396(s3)
        sw      s2, 1536(s3)
        sw      s2, 1676(s3)
        sw      s2, 1816(s3)
        sw      s2, 1956(s3)
        sw      s2, -2000(s4)
        sw      s2, -1860(s4)
        sw      s2, -1720(s4)
        sw      s2, -1580(s4)
        sw      s2, -1440(s4)
        sw      s2, -1300(s4)
        sw      s2, -1160(s4)
        sw      s2, -1020(s4)
        sw      s2, -880(s4)
        sw      s2, -740(s4)
        lui     a0, 12
        sw      a0, 1404(s3)
        sw      a0, 1544(s3)
        sw      a0, 1684(s3)
        sw      a0, 1824(s3)
        sw      a0, 1964(s3)
        lw      a0, 4(sp)
        sw      a0, 1748(s3)
        li      s0, 10
        li      s9, 1
        li      s8, -1
        li      s11, 12
        li      s10, 17
        li      s6, 1
        j       .LBB0_13
.LBB0_12:
        slti    a0, s1, 24
        addi    a0, a0, -1
        or      s9, a0, s9
        li      a1, 35
        mv      a0, s11
        call    __mulsi3@plt
        add     a0, s10, a0
        slli    a0, a0, 2
        add     a0, a0, s3
        sw      s5, 0(a0)
        mv      s5, s7
        beqz    s6, .LBB0_5
.LBB0_13:
        li      s1, 0
        li      a0, 1000
        j       .LBB0_15
.LBB0_14:
        addi    a0, a0, -1
        beqz    a0, .LBB0_17
.LBB0_15:
        lw      a1, -596(s4)
        lw      a2, -592(s4)
        andi    a1, a1, 1
        slli    a2, a2, 1
        andi    a2, a2, 2
        or      a1, a2, a1
        beqz    a1, .LBB0_14
        mv      s1, a1
        j       .LBB0_14
.LBB0_17:
        li      a1, 140
        mv      a0, s0
        call    __mulsi3@plt
        add     a0, a0, s3
        sw      zero, 4(a0)
        blt     s5, s0, .LBB0_19
        li      a1, 140
        mv      a0, s0
        call    __mulsi3@plt
        add     a0, a0, s3
        sw      zero, 144(a0)
        sw      zero, 284(a0)
        sw      zero, 424(a0)
        sw      zero, 564(a0)
.LBB0_19:
        li      a1, 35
        mv      a0, s11
        call    __mulsi3@plt
        add     a0, a0, s10
        slli    a0, a0, 2
        add     a0, a0, s3
        andi    s1, s1, 3
        sw      zero, 0(a0)
        li      a0, 2
        beq     s1, a0, .LBB0_22
        li      a0, 1
        bne     s1, a0, .LBB0_23
        slti    a0, s0, 2
        xori    a0, a0, 1
        sub     s0, s0, a0
        j       .LBB0_23
.LBB0_22:
        slti    a0, s0, 19
        add     s0, s0, a0
.LBB0_23:
        add     a0, s11, s9
        mv      s1, a0
        bgtz    a0, .LBB0_25
        li      s1, 2
.LBB0_25:
        mv      s11, s1
        li      a1, 23
        bge     a1, s1, .LBB0_27
        li      s11, 22
.LBB0_27:
        bgtz    a0, .LBB0_29
        li      s9, 1
.LBB0_29:
        add     s10, s10, s8
        li      a0, 33
        bge     a0, s10, .LBB0_31
        li      s10, 32
        li      s8, -1
        j       .LBB0_37
.LBB0_31:
        bgez    s8, .LBB0_37
        li      a0, 1
        bne     s10, a0, .LBB0_36
        slt     a0, s11, s0
        addi    a1, s0, 4
        slt     a1, a1, s11
        or      a0, a0, a1
        bnez    a0, .LBB0_35
        li      s8, 1
.LBB0_35:
        li      a1, 2
        sub     s10, a1, a0
        j       .LBB0_37
.LBB0_36:
        slti    a0, s10, 1
        addi    a0, a0, -1
        and     s6, a0, s6
        and     s10, a0, s10
.LBB0_37:
        li      a1, 140
        mv      a0, s0
        call    __mulsi3@plt
        add     a0, a0, s3
        lui     a1, 12
        sw      a1, 4(a0)
        mv      s7, s5
        blt     s5, s0, .LBB0_39
        li      a1, 140
        mv      a0, s0
        call    __mulsi3@plt
        add     a0, a0, s3
        lui     a1, 12
        sw      a1, 144(a0)
        sw      a1, 284(a0)
        sw      a1, 424(a0)
        sw      a1, 564(a0)
.LBB0_39:
        lw      s5, 8(sp)
        beqz    s6, .LBB0_12
        lw      s5, 4(sp)
        j       .LBB0_12

