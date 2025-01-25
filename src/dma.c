#include <arch/zxn.h>
#include <stdlib.h>
#include <z80.h>
#include "dma.h"

typedef struct {
  // header
  byte r6a;
  byte r0;
  word source;
  word length;
  byte r5;
  // payload
  byte r1;
  byte r1t;
  byte r2;
  byte r2t;
  byte r4;
  word destination;
  word r6b;
} dmaPayload;

static dmaPayload dmaMemoryPrep = {
  // header - 7 bytes
  0xc3, // 11000011 ; R6 reset dma
  0x7e, // 01111101 ; R0-Transfer mode, A -> B, will provide address and length
  0, // source address 
  0, // transfer length
  0x82, // 1000 0010 ; R5-Stop on end of block, RDY active LOW

  // payload - 9 bytes
  0, // R1 - from config
  2, // 0000 0010 - 2t timing for R1
  0, // R2 - to config
  2, // 0000 0010 - 2t timing for R2
  0xad, // 1010 1101 ; R4 Continuous mode, will provide destination
  0, // destination post/address,
  0x87cf // cf, 87 in reverse order (R6 load, R6 enable DMA)
};

#define DMA_WORKAROUND

void dmaRepeat(void) __z88dk_fastcall {
#ifdef DMA_WORKAROUND
  z80_otir(&dmaMemoryPrep, __IO_DMA, 16); // full program, needed on Zesarux
#else
  z80_outp(__IO_DMA, 0xCF); // 207
  z80_outp(__IO_DMA, 0x87); // 135
#endif
}

void dmaMemoryToMemory(const byte *restrict source, byte *restrict destination, word length) {
  dmaMemoryPrep.source = (word)source;
  dmaMemoryPrep.length = length;
  dmaMemoryPrep.r1 = 0x54; // 0101 0100 ; R1 - increment, from memory, bitmask
  dmaMemoryPrep.r2 = 0x50; // 0101 0000 ; R2 - increment, to memory, bitmask
  dmaMemoryPrep.destination = (word)destination;
  z80_otir(&dmaMemoryPrep, __IO_DMA, 16);
}

void dmaMemoryToPort(const byte *restrict source, word port, word length) {
  dmaMemoryPrep.source = (word)source;
  dmaMemoryPrep.length = length;
  dmaMemoryPrep.r1 = 0x54; // 0101 0100 ; R1 - increment, from memory, bitmask
  dmaMemoryPrep.r2 = 0x68; // 0110 1000 ; R2 - do not increment, to port, bitmask
  dmaMemoryPrep.destination = port;
  z80_otir(&dmaMemoryPrep, __IO_DMA, 16);
}

void fillWithDma(word destination, word length, byte value) {
  dmaMemoryPrep.source = (word)(&value);
  dmaMemoryPrep.length = length;
  dmaMemoryPrep.r1 = 0x64; // 0110 0100 ; R1 no increment, from memory, bitmask
  dmaMemoryPrep.r2 = 0x50; // 0101 0000 ; R2 increment, to memory, bitmask
  dmaMemoryPrep.destination = destination;
  z80_otir(&dmaMemoryPrep, __IO_DMA, 16);
}

void fillWithDmaRepeat(word destination, word length, byte value, byte times, word step) {
  dmaMemoryPrep.source = (word)(&value);
  dmaMemoryPrep.length = length;
  dmaMemoryPrep.r1 = 0x64; // 0110 0100 ; R1 no increment, from memory, bitmask
  dmaMemoryPrep.r2 = 0x50; // 0101 0000 ; R2 increment, to memory, bitmask
  z80_otir(&dmaMemoryPrep, __IO_DMA, 11); // just the header and R1 and R2

  dmaMemoryPrep.destination = destination;
  for(byte t=0; t!=times; ++t, dmaMemoryPrep.destination += step) {
    z80_otir(&dmaMemoryPrep.r4, __IO_DMA, 5); // R4 onwards
  }
}

static const byte dmaAudioBuf[] = {
  0x54, // 0101 0100 ; R1 increment, from memory
  0x02, // 0000 0010 ; no prescalar, 2t cycle

  0x68, // 0110 1000 ; R2 do not increment, to port
  0x22, // 0010 0010 ; want prescalar, use 2t cycle
  0x37, // ~16 Khz prescalar

  0xcd, // 1100 1101 ; R4 burst mode, dest value follows
  0xdf, 0xff, // Dest covox port L, H

  0xcf, 0x87 // R6 load, R6 enable DMA
};

void playWithDma(word source, word length) {
  dmaMemoryPrep.source = source;
  dmaMemoryPrep.length = length;
  z80_otir(&dmaMemoryPrep, __IO_DMA, 7); // just the header
  z80_otir(&dmaAudioBuf, __IO_DMA, 10);
}