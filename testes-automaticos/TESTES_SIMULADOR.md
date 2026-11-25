# Testes adicionais: execução do binário RV32I fora do Ripes

Estes testes complementam os do Ripes. O `pong.s` foi montado **sem nenhuma alteração** pelo assembler do LLVM (`clang --target=riscv32 -march=rv32i`) e ligado com o mesmo mapa de memória do Ripes: `.text` em `0x00000000`, `.data` em `0x10000000`, `sp = 0x7ffffff0`, LEDs em `0xF0000000` e D-Pad em `0xF0000DAC`. O binário foi executado num simulador RV32I escrito em Python (`rv32i.py`), que decodifica as instruções de máquina e implementa as ecalls 1, 4 e 10 como o Ripes.

> As imagens abaixo foram geradas a partir do conteúdo da matriz de LEDs simulada. **Não são capturas de tela do Ripes.**

## Como reproduzir

```text
clang --target=riscv32 -march=rv32i -c pong.s -o pong.o
ld.lld -m elf32lriscv --no-relax -Ttext=0x0 -Tdata=0x10000000 pong.o -o pong.elf
llvm-objcopy -O binary -j .text pong.elf text.bin
llvm-objcopy -O binary -j .data pong.elf data.bin
python3 testes_pong.py     # 34 casos
python3 partida.py         # partida completa, imagens e GIF
```

O assembler aceitou o programa com `-march=rv32i`, o que confirma que o código não usa instruções das extensões M ou C. O simulador também interrompe a execução se encontrar uma instrução da extensão M.

## Casos controlados (34 aprovados)

Antes de cada chamada, `s0`–`s11` recebem os valores 101 a 112. Depois do retorno, todo caso confere esses valores e `sp = 0x7ffffff0`, além do resultado esperado.

| Grupo | Casos |
|---|---|
| `passo` (20) | movimento livre; raquete sobe, desce, cima+baixo juntos, limites 1 e 19; paredes de cima, de baixo e da direita; canto superior direito; rebatida no centro, na primeira e na última linha da raquete; bola passa acima e abaixo; game over; partida encerrada não muda; bola indo para a direita na coluna 1; rebatida junto com reflexo na parede; raquete se move e rebate no mesmo quadro |
| `pixel` (3) | (0,0), (34,24) e (17,12): só o LED certo é escrito |
| Botões (6) | `ler_botoes` solto e com a seta direita; `esperar_controle` com cima (1), baixo (2), os dois (3) e só a esquerda (0) |
| Desenho e estado (4) | `desenhar` limpa uma tela cheia de lixo e pinta tudo; `apagar_moveis` preserva as bordas; bola magenta no game over; `iniciar_estado` |
| Mutação (1) | Com `addi t5, t0, 4` trocado por `3`, o caso da última linha da raquete falha, como esperado |

Os resultados estão em `resultados_testes.json`.

## Partida completa

`partida.py` executa o programa a partir de `main`, com `DELAY = 1000`. Um jogador automático aperta a seta direita para começar e depois usa cima/baixo para seguir a bola. Após 3 pontos, ele tenta se afastar da bola para perder (a quarta rebatida aconteceu mesmo assim). Depois do game over, ele solta os botões, aperta uma seta e joga uma segunda partida por 40 quadros.

Saída do console registrada (`console_partida.txt`):

```text
PONG RV32I - aperte uma seta para comecar
Cima/baixo movem a raquete.
Pontos: 1
Pontos: 2
Pontos: 3
Pontos: 4
GAME OVER! Pontos: 4
Solte os botoes e aperte uma seta para reiniciar.
Pontos: 1
```

Foram executadas 3.174.959 instruções em 324 quadros.

| Momento | Imagem |
|---|---|
| Início da partida | `partida1_inicio.png` |
| Rebatida (Pontos: 1) | `partida1_rebatida_1.png` |
| Game over, bola magenta na coluna 0 | `partida1_game_over.png` |
| Reinício e segunda partida | `partida2_inicio.png`, `partida2_rebatida_1.png`, `partida2_em_andamento.png` |
| Partida inteira animada | `partida.gif` |
