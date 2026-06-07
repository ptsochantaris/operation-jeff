#ifndef __OJ_COPPER_H__
#define __OJ_COPPER_H__

// per-power-up cloud tints for copperEffectCloud(...): low, mid, high anchors
#define SHIELD_CLOUD    RGB332(0, 0, 0), RGB332(1, 3, 3), RGB332(4, 4, 7)
#define UMBRELLA_CLOUD  RGB332(0, 0, 0), RGB332(5, 0, 3), RGB332(5, 2, 6)
#define GUNBOOST_CLOUD  RGB332(0, 0, 0), RGB332(6, 2, 0), RGB332(7, 4, 1)
#define SLOW_CLOUD      RGB332(0, 0, 0), RGB332(4, 4, 1), RGB332(5, 5, 1)

void copperInit(void) __z88dk_fastcall;

void copperEffectCloud(byte low, byte mid, byte high) __z88dk_callee;
void copperEffectFire(void) __z88dk_fastcall;
void copperEffectFlash(void) __z88dk_fastcall;
void copperEffectOff(void) __z88dk_fastcall;
void copperEffectUpdate(void) __z88dk_fastcall;

#endif
