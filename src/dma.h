#ifndef _DMA_H_
#define _DMA_H_

#include "types.h"

void dmaMemoryToMemory(const byte *restrict source, byte *restrict destination, word length) __preserves_regs(iyl,iyh) __z88dk_callee __smallc;
void dmaMemoryToPort(const byte *restrict source, word port, word length) __preserves_regs(iyl,iyh) __z88dk_callee __smallc;
void fillWithDma(word destination, word length, byte value) __preserves_regs(iyl,iyh) __z88dk_callee __smallc;
void fillWithDmaRepeat(word destination, word length, byte value, word times, word step) __preserves_regs(iyl,iyh) __z88dk_callee __smallc;

void playWithDma(word source, word length, byte prescalar, byte loop) __preserves_regs(iyl,iyh) __z88dk_callee __smallc;
void dmaWaitForEnd(void) __preserves_regs(d,e,h,l,iyl,iyh) __z88dk_fastcall;
void dmaResetStatus(void) __preserves_regs(d,e,h,l,iyl,iyh) __z88dk_fastcall;
void stopDma(void) __preserves_regs(d,e,h,l,iyl,iyh) __z88dk_fastcall;

#endif
