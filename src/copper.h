#ifndef __OJ_COPPER_H__
#define __OJ_COPPER_H__

void copperInit(void) __z88dk_fastcall;
void copperCycle(void) __z88dk_fastcall;
void copperForeground(byte colour1, byte colour2, byte colour3, byte effectType) __z88dk_callee;
void copperShutdown(void) __z88dk_fastcall;

#endif
