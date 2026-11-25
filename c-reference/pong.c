/*
 * Versão em C do mesmo Pong, só para comparação.
 * Cole no Compiler Explorer (godbolt.org), compilador Clang para RISC-V 32 bits,
 * com as opções:  -O2 -march=rv32i -mabi=ilp32
 * e compare o assembly gerado com pong.s (veja o RELATORIO.md).
 */
#include <stdint.h>

#define LED   ((volatile uint32_t *)0xF0000000)
#define DPAD  ((volatile uint32_t *)0xF0000DAC)   /* [0]=UP [1]=DOWN [2]=LEFT [3]=RIGHT */
#define W 35
#define H 25
#define DELAY 1000

enum { C_BORDA = 0x202060, C_RAQUETE = 0x00C000, C_BOLA = 0xFFFF00, C_PERDA = 0xFF00FF };

typedef struct { int x, y, dx, dy, raquete, pontos, ativa; } Estado;

static void pixel(int x, int y, uint32_t cor) { LED[y * W + x] = cor; }

static void pintar_moveis(const Estado *e, int pintar) {
    for (int y = e->raquete; y < e->raquete + 5; y++)
        pixel(1, y, pintar ? C_RAQUETE : 0);
    pixel(e->x, e->y, pintar ? (e->ativa ? C_BOLA : C_PERDA) : 0);
}

static void desenhar(const Estado *e) {
    for (int i = 0; i < W * H; i++) LED[i] = 0;
    for (int x = 0; x < W; x++) { pixel(x, 0, C_BORDA); pixel(x, H - 1, C_BORDA); }
    for (int y = 1; y < H - 1; y++) pixel(W - 1, y, C_BORDA);
    pintar_moveis(e, 1);
}

static void passo(Estado *e, uint32_t botoes) {
    if (!e->ativa) return;
    botoes &= 3;
    if (botoes == 1 && e->raquete > 1) e->raquete--;
    else if (botoes == 2 && e->raquete < H - 6) e->raquete++;
    int x = e->x + e->dx, y = e->y + e->dy;
    if (y <= 0)     { y = 2;     e->dy = 1; }
    if (y >= H - 1) { y = H - 3; e->dy = -1; }
    if (x >= W - 1) { x = W - 3; e->dx = -1; }
    if (e->dx < 0) {
        if (x == 1 && y >= e->raquete && y <= e->raquete + 4) {
            x = 2; e->dx = 1; e->pontos++;
        } else if (x <= 0) {
            x = 0; e->ativa = 0;
        }
    }
    e->x = x; e->y = y;
}

static uint32_t ler_botoes(void) { return DPAD[0] | DPAD[1] | DPAD[2] | DPAD[3]; }

static uint32_t esperar_controle(void) {
    uint32_t comando = 0;
    for (int i = 0; i < DELAY; i++) {
        uint32_t b = (DPAD[0] & 1) | ((DPAD[1] & 1) << 1);
        if (b) comando = b;
    }
    return comando;
}

int main(void) {
    Estado e = {17, 12, -1, 1, 10, 0, 1};
    desenhar(&e);
    for (;;) {
        while (ler_botoes()) {}
        while (!ler_botoes()) {}
        e = (Estado){17, 12, -1, 1, 10, 0, 1};
        desenhar(&e);
        while (e.ativa) {
            uint32_t b = esperar_controle();
            pintar_moveis(&e, 0);
            passo(&e, b);
            pintar_moveis(&e, 1);
        }
    }
}
