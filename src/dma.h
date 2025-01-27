#ifndef _DMA_H_
#define _DMA_H_

#include "types.h"

void dmaMemoryToMemory(const byte *restrict source, byte *restrict destination, word length);
void dmaMemoryToPort(const byte *restrict source, word port, word length);
void fillWithDma(word destination, word length, byte value);
void fillWithDmaRepeat(word destination, word length, byte value, byte times, word step);
void dmaRepeat(void) __z88dk_fastcall;

void playWithDma(word source, word length, byte prescalar, byte loop);
void stopDma(void) __z88dk_fastcall;

#endif