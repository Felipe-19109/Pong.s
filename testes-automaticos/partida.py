"""Executa o pong.s inteiro a partir de main, com um jogador automatico apertando o D-Pad,
e salva quadros da matriz de LEDs (PNG e GIF) e a saida do console."""
import json
from PIL import Image, ImageDraw
from rv32i import CPU, load_symbols, s32, LED_W, LED_H

text = open("text.bin", "rb").read(); data = open("data.bin", "rb").read()
S = load_symbols("pong.elf"); EST = S["estado"]
cpu = CPU(text, data)
TAM = 16

def imagem(led):
    img = Image.new("RGB", (LED_W * TAM, LED_H * TAM), (18, 18, 18))
    d = ImageDraw.Draw(img)
    for i, v in enumerate(led):
        x, y = i % LED_W, i // LED_W
        cor = ((v >> 16) & 255, (v >> 8) & 255, v & 255) if v else (40, 40, 40)
        d.ellipse([x * TAM + 2, y * TAM + 2, x * TAM + TAM - 3, y * TAM + TAM - 3], fill=cor)
    return img

def estado(): return [s32(cpu.lw(EST + 4 * i)) for i in range(7)]

quadros, capturas, log = [], {}, []
partida, quadro, espera_inicio = 1, 0, 0
META = 3  # pontos antes de o jogador "errar" de proposito
pts_antes = 0
while True:
    pc = cpu.pc
    if pc == S["soltar"]:
        cpu.dpad = [0, 0, 0, 0]
    elif pc == S["pressionar"]:
        espera_inicio += 1
        if espera_inicio == 50:
            cpu.dpad = [0, 0, 0, 1]  # aperta a seta direita para comecar
            log.append(f"partida {partida}: seta direita pressionada para iniciar")
    elif pc == S["jogo"]:
        espera_inicio = 0
        st = estado()
        if quadro == 0:
            capturas[f"partida{partida}_inicio"] = list(cpu.led)
        if st[5] != pts_antes and st[5] > 0:
            capturas.setdefault(f"partida{partida}_rebatida_{st[5]}", list(cpu.led))
        pts_antes = st[5]
        quadros.append(imagem(cpu.led))
        quadro += 1
        bx, by, topo, pts = st[0], st[1], st[4], st[5]
        centro = topo + 2
        if (partida == 1 and pts < META) or partida == 2:
            cima, baixo = by < centro, by > centro  # segue a bola
        else:
            cima, baixo = False, False
            if partida == 1:  # foge da bola para perder
                cima, baixo = (by > centro, by < centro) if abs(by - centro) < 6 else (False, False)
        cpu.dpad = [int(cima), int(baixo), 0, 0]
        if partida == 2 and quadro == 40:
            capturas["partida2_em_andamento"] = list(cpu.led)
            break
    elif pc == S["nova_partida"] and partida == 1 and quadro > 0:
        capturas["partida1_game_over"] = list(cpu.led)
        for _ in range(15): quadros.append(imagem(cpu.led))
        partida, quadro, pts_antes = 2, 0, 0
    cpu.step()

console = "".join(cpu.console)
print(console)
print(f"instrucoes executadas: {cpu.instret}, quadros: {len(quadros)}")
for nome, led in capturas.items():
    imagem(led).save(f"{nome}.png")
print(sorted(capturas))
quadros[0].save("partida.gif", save_all=True, append_images=quadros[1:], duration=60, loop=0)
open("console_partida.txt", "w").write(console)
json.dump({"log": log, "instrucoes": cpu.instret, "quadros": len(quadros)}, open("partida.json", "w"), indent=2)
