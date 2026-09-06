#ifndef _JEFF_H_
#define _JEFF_H_

#include "types.h"

extern byte heightMap[];

void initJeffs(void) __z88dk_fastcall;
void updateJeffs(void) __z88dk_fastcall;
void jeffKillAll(byte retireImmediately) __z88dk_fastcall;
void jeffKillAllAt(word x, word y) __z88dk_callee;
void loadHeightmap(const struct ResourceInfo *restrict info) __z88dk_fastcall;
void jeffFlashAll(void) __z88dk_fastcall;
void jeffsMagnetise(void) __z88dk_fastcall;

#endif
