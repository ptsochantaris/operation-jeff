#ifndef _UTILITY_H_
#define _UTILITY_H_

#include "types.h"

#define TILEMAP_PAGE 11
#define LAYER2_BASE_PAGE 18 // ...28
#define COPPER_IMAGE_PAGE 213
#define PREFETCH_BASE_PAGE 214 // ...223

word random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void srand16(word seed) __preserves_regs(a,b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void stackClear(word base, word len, byte pattern) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void copperAddress(word address) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void copperStop(void) __preserves_regs(a,b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;

#endif
