#ifndef _DMA_H_
#define _DMA_H_

#include "types.h"

// All of these program the zxnDDMA of core 3.03.00, which the NEX header
// requires. Read the notes at the top of dma-ro.asm before adding a transfer -
// in particular the one about hardware IM2 holding the DMA back.
//
// "Page" always means an 8K page. Physical transfers can't reach banks 5 and 7
// (the ULA screen and the tilemap live in bank 5): use the MMU-addressed ones.

// Source by physical address, so `page` needn't be mapped. `address` is where the
// data would sit with `page` in its MMU slot; only its low 13 bits are used.
void dmaPageToPort(byte page, const byte *restrict address, word port, word length) __z88dk_callee __smallc;

// Memory to memory by physical address (up to 64K); addresses as for dmaPageToPort.
void dmaCopyPhysical(byte sourcePage, const byte *restrict sourceAddress,
                     byte destinationPage, byte *restrict destinationAddress, word length) __z88dk_callee __smallc;

// Fill mode through the MMU: `rows` runs of `rowLength` bytes, `stride` apart.
void fillWithDma2D(word destination, word rowLength, word rows, word stride, byte value) __z88dk_callee __smallc;
#define fillWithDma(destination, length, value) fillWithDma2D((destination), (length), 1, 0, (value))

// Whole pages by physical address, in one transfer however many there are.
void dmaFillPages(byte page, byte count, byte value) __z88dk_callee __smallc;
void dmaCopyPages(byte sourcePage, byte destinationPage, byte count) __z88dk_callee __smallc;

// A columns x rows rectangle of Layer 2 and a stash at `offset` in `page`, packed
// a screen column (`rows` bytes) at a time. toScreen = 0 copies the screen into
// the stash, 1 puts the stash back on the screen.
void dmaLayer2Copy(byte page, word offset, word x, word y, word columns, word rows, byte toScreen) __z88dk_callee __smallc;

// Reset the controller, clearing every zxnDDMA mode flag our transfers leave set.
// Call before handing control to anything that may use the DMA itself (esxDOS).
void dmaReset(void) __z88dk_fastcall;

// Re-run whatever the controller was last programmed with.
void dmaRepeat(void) __z88dk_fastcall;

// Unused - kept for reference
// void dmaWaitForEnd(void) __preserves_regs(b,c,d,e,h,l,iyl,iyh) __z88dk_fastcall;
// void dmaResetStatus(void) __preserves_regs(b,c,d,e,h,l,iyl,iyh) __z88dk_fastcall;
// void stopDma(void) __preserves_regs(b,c,d,e,h,l,iyl,iyh) __z88dk_fastcall;

extern volatile byte copperDmaResident; // 1 = controller still holds the copper transfer

#endif
