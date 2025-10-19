#ifndef _UTILITY_H_
#define _UTILITY_H_

#include "types.h"

int random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void stackClear(word base, word len, byte pattern) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;

#endif
