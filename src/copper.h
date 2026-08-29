#ifndef __OJ_COPPER_H__
#define __OJ_COPPER_H__

// per-power-up cloud tints for copperEffectCloud(...): low, mid, high anchors
#define SHIELD_CLOUD    RGB332(0, 0, 1), RGB332(0, 0, 7), RGB332(1, 1, 6)
#define UMBRELLA_CLOUD  RGB332(1, 0, 1), RGB332(3, 0, 2), RGB332(3, 0, 2)
#define GUNBOOST_CLOUD  RGB332(1, 1, 0), RGB332(5, 3, 0), RGB332(5, 3, 0)
#define SLOW_CLOUD      RGB332(1, 1, 0), RGB332(4, 4, 0), RGB332(4, 4, 0)

void copperInit(void) __z88dk_fastcall;

void copperEffectCloud(byte low, byte mid, byte high) __z88dk_callee;
void copperEffectFire(void) __z88dk_fastcall;
void copperEffectFlash(void) __z88dk_fastcall;
void copperEffectOff(void) __z88dk_fastcall;
void copperEffectUpdate(void) __z88dk_fastcall;

#endif
