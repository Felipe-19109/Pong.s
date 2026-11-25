"""Simulador RV32I minimo (sem M/C) com o mapa de memoria e as ecalls do Ripes.
Executa o binario gerado pelo assembler do LLVM a partir do pong.s original."""
import struct, subprocess, re

LED_BASE, LED_W, LED_H = 0xF0000000, 35, 25
DPAD_BASE = 0xF0000DAC
TEXT_BASE, DATA_BASE, SP0 = 0x0, 0x10000000, 0x7FFFFFF0
MASK = 0xFFFFFFFF

def sx(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v

def s32(v):
    v &= MASK
    return v - (1 << 32) if v >> 31 else v

def load_symbols(elf):
    out = subprocess.check_output(["llvm-objdump", "-t", elf], text=True)
    syms = {}
    for line in out.splitlines():
        m = re.match(r"([0-9a-f]{8})\s+\S+\s+\S*\s*\.(text|data)\s+[0-9a-f]+\s+(\S+)$", line)
        if m and not m.group(3).startswith(".L"):
            syms[m.group(3)] = int(m.group(1), 16)
    return syms

class CPU:
    def __init__(self, text, data):
        self.text = text
        self.data = bytearray(data) + bytearray(4096)
        self.stack = bytearray(64 * 1024)
        self.led = [0] * (LED_W * LED_H)
        self.dpad = [0, 0, 0, 0]
        self.x = [0] * 32
        self.x[2] = SP0
        self.pc = TEXT_BASE
        self.console = []
        self.instret = 0
        self.halted = False
        self.mem_ops = []  # acessos fora das regioes validas

    # ---------- memoria ----------
    def lw(self, a):
        if a & 3:
            raise RuntimeError(f"lw desalinhado em {a:#x} (pc={self.pc:#x})")
        if DATA_BASE <= a < DATA_BASE + len(self.data):
            return struct.unpack_from("<I", self.data, a - DATA_BASE)[0]
        if SP0 - len(self.stack) + 16 <= a < SP0 + 16:
            return struct.unpack_from("<I", self.stack, a - (SP0 - len(self.stack) + 16))[0]
        if LED_BASE <= a < LED_BASE + 4 * len(self.led):
            return self.led[(a - LED_BASE) // 4]
        if DPAD_BASE <= a < DPAD_BASE + 16:
            return self.dpad[(a - DPAD_BASE) // 4]
        raise RuntimeError(f"lw fora do mapa em {a:#x} (pc={self.pc:#x})")

    def sw(self, a, v):
        v &= MASK
        if a & 3:
            raise RuntimeError(f"sw desalinhado em {a:#x} (pc={self.pc:#x})")
        if DATA_BASE <= a < DATA_BASE + len(self.data):
            struct.pack_into("<I", self.data, a - DATA_BASE, v); return
        if SP0 - len(self.stack) + 16 <= a < SP0 + 16:
            struct.pack_into("<I", self.stack, a - (SP0 - len(self.stack) + 16), v); return
        if LED_BASE <= a < LED_BASE + 4 * len(self.led):
            self.led[(a - LED_BASE) // 4] = v; return
        raise RuntimeError(f"sw fora do mapa em {a:#x} (pc={self.pc:#x})")

    def lbu(self, a):
        return self.data[a - DATA_BASE]

    def read_str(self, a):
        s = bytearray()
        while self.lbu(a):
            s.append(self.lbu(a)); a += 1
        return s.decode()

    # ---------- execucao ----------
    def step(self):
        pc = self.pc
        ins = struct.unpack_from("<I", self.text, pc - TEXT_BASE)[0]
        op = ins & 0x7F
        rd = (ins >> 7) & 31
        f3 = (ins >> 12) & 7
        rs1 = (ins >> 15) & 31
        rs2 = (ins >> 20) & 31
        f7 = ins >> 25
        x = self.x
        npc = pc + 4
        if op == 0x37:  # lui
            v = ins & 0xFFFFF000
        elif op == 0x17:  # auipc
            v = (pc + (ins & 0xFFFFF000)) & MASK
        elif op == 0x6F:  # jal
            imm = sx(((ins >> 31) << 20) | (((ins >> 12) & 0xFF) << 12) | (((ins >> 20) & 1) << 11) | (((ins >> 21) & 0x3FF) << 1), 21)
            v = npc; npc = (pc + imm) & MASK
        elif op == 0x67:  # jalr
            v = npc; npc = (x[rs1] + sx(ins >> 20, 12)) & ~1 & MASK
        elif op == 0x63:  # branches
            imm = sx(((ins >> 31) << 12) | (((ins >> 7) & 1) << 11) | (((ins >> 25) & 0x3F) << 5) | (((ins >> 8) & 0xF) << 1), 13)
            a, b = x[rs1], x[rs2]
            take = {0: a == b, 1: a != b, 4: s32(a) < s32(b), 5: s32(a) >= s32(b), 6: a < b, 7: a >= b}[f3]
            if take: npc = (pc + imm) & MASK
            rd = 0; v = 0
        elif op == 0x03:  # loads (so lw e usado)
            if f3 != 2: raise RuntimeError(f"load nao suportado em {pc:#x}")
            v = self.lw((x[rs1] + sx(ins >> 20, 12)) & MASK)
        elif op == 0x23:  # stores (so sw)
            if f3 != 2: raise RuntimeError(f"store nao suportado em {pc:#x}")
            imm = sx(((ins >> 25) << 5) | ((ins >> 7) & 31), 12)
            self.sw((x[rs1] + imm) & MASK, x[rs2]); rd = 0; v = 0
        elif op == 0x13:  # OP-IMM
            imm = sx(ins >> 20, 12); a = x[rs1]; sh = rs2
            if f3 == 0: v = a + imm
            elif f3 == 1: v = a << sh
            elif f3 == 2: v = int(s32(a) < imm)
            elif f3 == 3: v = int(a < (imm & MASK))
            elif f3 == 4: v = a ^ (imm & MASK)
            elif f3 == 5: v = (s32(a) >> sh) if f7 & 0x20 else (a >> sh)
            elif f3 == 6: v = a | (imm & MASK)
            else: v = a & (imm & MASK)
        elif op == 0x33:  # OP
            if f7 == 1: raise RuntimeError(f"instrucao da extensao M em {pc:#x}")
            a, b = x[rs1], x[rs2]
            if f3 == 0: v = a - b if f7 & 0x20 else a + b
            elif f3 == 1: v = a << (b & 31)
            elif f3 == 2: v = int(s32(a) < s32(b))
            elif f3 == 3: v = int(a < b)
            elif f3 == 4: v = a ^ b
            elif f3 == 5: v = (s32(a) >> (b & 31)) if f7 & 0x20 else (a >> (b & 31))
            elif f3 == 6: v = a | b
            else: v = a & b
        elif op == 0x73:  # ecall
            self.ecall(); rd = 0; v = 0
        else:
            raise RuntimeError(f"opcode desconhecido {ins:#010x} em {pc:#x}")
        if rd: x[rd] = v & MASK
        self.pc = npc
        self.instret += 1

    def ecall(self):
        a7, a0 = self.x[17], self.x[10]
        if a7 == 4: self.console.append(self.read_str(a0))
        elif a7 == 1: self.console.append(str(s32(a0)))
        elif a7 == 10: self.halted = True
        else: raise RuntimeError(f"ecall {a7} nao suportada")

    def call(self, addr, args=(), limit=10_000_000):
        """Chama uma sub-rotina e volta quando ela retorna para o endereco sentinela."""
        SENT = 0xFFFFFFF0
        for i, a in enumerate(args): self.x[10 + i] = a & MASK
        self.x[1] = SENT; self.pc = addr
        n = 0
        while self.pc != SENT:
            self.step(); n += 1
            if n > limit: raise RuntimeError("limite de instrucoes")
        return self.x[10]
