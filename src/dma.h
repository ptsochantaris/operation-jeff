#ifndef _DMA_H_
#define _DMA_H_

#include "types.h"

void dmaMemoryToMemory(const byte *restrict source, byte *restrict destination, word length) __z88dk_callee;
void dmaMemoryToPort(const byte *restrict source, word port, word length) __z88dk_callee;
void fillWithDma(word destination, word length, byte value) __z88dk_callee;
void fillWithDmaRepeat(word destination, word length, byte value, byte times, word step) __z88dk_callee;

void playWithDma(word source, word length, byte prescalar, byte loop) __z88dk_callee;
void stopDma(void) __z88dk_fastcall;

#endif