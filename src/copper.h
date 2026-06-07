#ifndef __OJ_COPPER_H__
#define __OJ_COPPER_H__

// 8-bit fallback colour (reg 0x4A) is RRRGGGBB: r 0..7, g 0..7, b 0..3
#define RGB332(r, g, b) (byte)(((r) << 5) | ((g) << 2) | (b))

// per-power-up cloud tints for copperEffectCloud(...): low, mid, high anchors
#define SHIELD_CLOUD    RGB332(0, 0, 1), RGB332(1, 4, 3), RGB332(6, 7, 3)   // blue -> cyan -> white
#define UMBRELLA_CLOUD  RGB332(1, 0, 1), RGB332(5, 0, 3), RGB332(7, 6, 3)   // magenta -> pink-white
#define GUNBOOST_CLOUD  RGB332(1, 0, 0), RGB332(6, 2, 0), RGB332(7, 5, 1)   // dark red -> orange -> yellow
#define SLOW_CLOUD      RGB332(1, 1, 0), RGB332(4, 4, 1), RGB332(6, 6, 2)   // muted yellow

void copperInit(void) __z88dk_fastcall;

// Background effect controller (drives the copper). Activate on state change,
// then call copperEffectUpdate() once per frame.
void copperEffectCloud(byte low, byte mid, byte high) __z88dk_callee;
void copperEffectFire(void) __z88dk_fastcall;
void copperEffectFlash(void) __z88dk_fastcall;
void copperEffectOff(void) __z88dk_fastcall;
void copperEffectUpdate(void) __z88dk_fastcall;

#endif
