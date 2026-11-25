"""Testes automaticos do pong.s (binario montado pelo LLVM, executado no simulador rv32i.py)."""
import json, sys
from rv32i import CPU, load_symbols, s32, SP0, LED_BASE, DPAD_BASE, LED_W, LED_H

text = open("text.bin", "rb").read()
data = open("data.bin", "rb").read()
S = load_symbols("pong.elf")
EST = S["estado"]
BORDA, VERDE, AMARELO, MAGENTA = 0x202060, 0x00C000, 0xFFFF00, 0xFF00FF

resultados = []

def registrar(nome, ok, detalhe=""):
    resultados.append({"caso": nome, "aprovado": bool(ok), "detalhe": detalhe})
    print(("OK   " if ok else "FALHA") + f"  {nome}" + (f"  ({detalhe})" if detalhe and not ok else ""))

def nova_cpu():
    c = CPU(text, data)
    for i, r in enumerate([8, 9, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]):
        c.x[r] = 101 + i  # s0..s11 = 101..112
    return c

def conferir_abi(c, nome):
    s = [c.x[r] for r in [8, 9, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]]
    return s == list(range(101, 113)) and c.x[2] == SP0

def ler_estado(c):
    return [s32(c.lw(EST + 4 * i)) for i in range(7)]

def gravar_estado(c, st):
    for i, v in enumerate(st): c.sw(EST + 4 * i, v)

# ---------------- passo: movimento e colisoes ----------------
# (nome, estado inicial [x,y,dx,dy,topo,pontos,ativa], botoes, estado esperado)
casos_passo = [
    ("livre",                 [17,12,-1, 1,10,0,1], 0, [16,13,-1, 1,10,0,1]),
    ("raquete_sobe",          [17,12,-1, 1,10,0,1], 1, [16,13,-1, 1, 9,0,1]),
    ("raquete_desce",         [17,12,-1, 1,10,0,1], 2, [16,13,-1, 1,11,0,1]),
    ("cima_e_baixo_juntos",   [17,12,-1, 1,10,0,1], 3, [16,13,-1, 1,10,0,1]),
    ("raquete_limite_topo",   [17,12,-1, 1, 1,0,1], 1, [16,13,-1, 1, 1,0,1]),
    ("raquete_limite_baixo",  [17,12,-1, 1,19,0,1], 2, [16,13,-1, 1,19,0,1]),
    ("parede_cima",           [10, 1, 1,-1,10,0,1], 0, [11, 2, 1, 1,10,0,1]),
    ("parede_baixo",          [10,23, 1, 1,10,0,1], 0, [11,22, 1,-1,10,0,1]),
    ("parede_direita",        [33,10, 1, 1,10,0,1], 0, [32,11,-1, 1,10,0,1]),
    ("canto_superior_direito",[33, 1, 1,-1,10,0,1], 0, [32, 2,-1, 1,10,0,1]),
    ("rebatida_centro",       [ 2,11,-1, 1,10,0,1], 0, [ 2,12, 1, 1,10,1,1]),
    ("rebatida_primeira_linha",[2, 9,-1, 1,10,0,1], 0, [ 2,10, 1, 1,10,1,1]),
    ("rebatida_ultima_linha", [ 2,13,-1, 1,10,2,1], 0, [ 2,14, 1, 1,10,3,1]),
    ("bola_passa_acima",      [ 2, 8,-1, 1,10,0,1], 0, [ 1, 9,-1, 1,10,0,1]),
    ("bola_passa_abaixo",     [ 2,14,-1, 1,10,0,1], 0, [ 1,15,-1, 1,10,0,1]),
    ("game_over",             [ 1, 8,-1, 1,10,3,1], 0, [ 0, 9,-1, 1,10,3,0]),
    ("partida_encerrada",     [ 0, 9,-1, 1,10,3,0], 1, [ 0, 9,-1, 1,10,3,0]),
    ("bola_indo_direita_col1",[ 1,12, 1, 1,10,0,1], 0, [ 2,13, 1, 1,10,0,1]),
    ("rebatida_com_parede",   [ 2, 1,-1,-1, 1,0,1], 0, [ 2, 2, 1, 1, 1,1,1]),
    ("raquete_move_e_rebate", [ 2,10,-1,-1,10,0,1], 1, [ 2, 9, 1,-1, 9,1,1]),
]
for nome, ini, bot, esp in casos_passo:
    c = nova_cpu(); gravar_estado(c, ini)
    c.call(S["passo"], [EST, bot])
    obt = ler_estado(c)
    registrar(f"passo/{nome}", obt == esp and conferir_abi(c, nome), f"esperado {esp}, obtido {obt}")

# ---------------- pixel ----------------
for nome, (px, py) in [("pixel_primeiro", (0, 0)), ("pixel_ultimo", (34, 24)), ("pixel_meio", (17, 12))]:
    c = nova_cpu(); c.call(S["pixel"], [px, py, 0x123456, LED_BASE])
    idx = py * 35 + px
    ok = c.led[idx] == 0x123456 and sum(1 for v in c.led if v) == 1
    registrar(nome, ok and conferir_abi(c, nome), f"indice {idx}")

# ---------------- botoes ----------------
c = nova_cpu(); r = c.call(S["ler_botoes"], [DPAD_BASE]); registrar("ler_botoes_soltos", r == 0 and conferir_abi(c, ""))
c = nova_cpu(); c.dpad = [0, 0, 0, 1]; r = c.call(S["ler_botoes"], [DPAD_BASE]); registrar("ler_botoes_direita", r == 1 and conferir_abi(c, ""))
c = nova_cpu(); c.dpad = [1, 0, 0, 0]; r = c.call(S["esperar_controle"], [DPAD_BASE]); registrar("esperar_controle_cima", r == 1 and conferir_abi(c, ""))
c = nova_cpu(); c.dpad = [0, 1, 0, 0]; r = c.call(S["esperar_controle"], [DPAD_BASE]); registrar("esperar_controle_baixo", r == 2 and conferir_abi(c, ""))
c = nova_cpu(); c.dpad = [1, 1, 0, 0]; r = c.call(S["esperar_controle"], [DPAD_BASE]); registrar("esperar_controle_dois", r == 3 and conferir_abi(c, ""))
c = nova_cpu(); c.dpad = [0, 0, 1, 0]; r = c.call(S["esperar_controle"], [DPAD_BASE]); registrar("esperar_controle_ignora_esquerda", r == 0 and conferir_abi(c, ""))

# ---------------- desenho ----------------
def esperado_tela(st):
    t = [0] * 875
    for xx in range(35): t[xx] = BORDA; t[24 * 35 + xx] = BORDA
    for yy in range(1, 24): t[yy * 35 + 34] = BORDA
    for yy in range(st[4], st[4] + 5): t[yy * 35 + 1] = VERDE
    t[st[1] * 35 + st[0]] = AMARELO if st[6] else MAGENTA
    return t

c = nova_cpu(); c.led = [0xABCDEF] * 875; gravar_estado(c, [17,12,-1,1,10,0,1])
c.call(S["desenhar"], [EST, LED_BASE]); registrar("desenhar_tela_completa", c.led == esperado_tela([17,12,-1,1,10,0,1]) and conferir_abi(c, ""))

c = nova_cpu(); gravar_estado(c, [17,12,-1,1,10,0,1]); c.call(S["desenhar"], [EST, LED_BASE])
c.call(S["apagar_moveis"], [EST, LED_BASE])
so_bordas = esperado_tela([17,12,-1,1,10,0,1])
for yy in range(10, 15): so_bordas[yy * 35 + 1] = 0
so_bordas[12 * 35 + 17] = 0
registrar("apagar_moveis_mantem_bordas", c.led == so_bordas and conferir_abi(c, ""))

c = nova_cpu(); gravar_estado(c, [0,9,-1,1,10,3,0]); c.call(S["desenhar"], [EST, LED_BASE])
registrar("bola_magenta_no_game_over", c.led[9 * 35 + 0] == MAGENTA and conferir_abi(c, ""))

c = nova_cpu(); gravar_estado(c, [5,5,1,1,3,9,0]); c.call(S["iniciar_estado"], [EST])
registrar("iniciar_estado", ler_estado(c) == [17,12,-1,1,10,0,1] and conferir_abi(c, ""))

# mutacao: o teste deve detectar um erro proposital
import struct
mut = bytearray(text)
addr = None
# procura "addi t5, t0, 4" (rd=t5=30, rs1=t0=5, imm=4) dentro de passo
for a in range(S["passo"], S["ler_botoes"], 4):
    ins = struct.unpack_from("<I", mut, a)[0]
    if ins == (4 << 20) | (5 << 15) | (0 << 12) | (30 << 7) | 0x13:
        addr = a
struct.pack_into("<I", mut, addr, (3 << 20) | (5 << 15) | (30 << 7) | 0x13)
c = CPU(bytes(mut), data); gravar_estado(c, [2,13,-1,1,10,2,1]); c.call(S["passo"], [EST, 0])
registrar("mutacao_detectada (addi t5,t0,4 -> 3)", ler_estado(c) != [2,14,1,1,10,3,1])

ok = sum(r["aprovado"] for r in resultados)
print(f"\n{ok}/{len(resultados)} casos aprovados")
json.dump(resultados, open("resultados_testes.json", "w"), indent=2, ensure_ascii=False)
sys.exit(0 if ok == len(resultados) else 1)
