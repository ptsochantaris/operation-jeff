#ifndef _UTILITY_H_
#define _UTILITY_H_

#include "types.h"

#define TILEMAP_PAGE 11
#define LAYER2_BASE_PAGE 18 // ...28
#define PREFETCH_BASE_PAGE 214 // ...223

// One 8K page of banked scratch buffers, so none of them costs main-bank RAM. The
// CPU reaches it by borrowing MMU3 (mmu3Borrow(SCRATCH_PAGE), which maps it at
// 0x6000), the DMA by physical address. Sharing one page means borrows from
// different users nest cleanly - a fade during a copper effect maps the same
// page both want. makeAssets.swift's ASSET_PAGE_LIMIT keeps the packer off it.
#define SCRATCH_PAGE 213
#define SCRATCH_WINDOW 0x6000
#define COPPER_IMAGE_OFFSET   0x0000 // ..0x07FF  copper.c; the largest program is 1162 bytes
#define PALETTE_BUFFER_OFFSET 0x0800 // ..0x09FF  screen.c; 256 9-bit colours
#define PALETTE_STAGE_OFFSET  0x0A00 // ..0x0DFF  a compressed palette, staged for decompress
                                     //           (makeAssets.swift fails the build past 1K)
#define ARTWORK_STASH_OFFSET  0x1000 // ..0x12AF  gameover.c
// graphics-ro.asm has its own copy of PALETTE_BUFFER and SCRATCH_PAGE - keep in step
#define paletteBuffer ((byte *)(SCRATCH_WINDOW + PALETTE_BUFFER_OFFSET))
#define paletteStage  ((byte *)(SCRATCH_WINDOW + PALETTE_STAGE_OFFSET))

word random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void srand16(word seed) __preserves_regs(a,b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void copperAddress(word address) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void copperStop(void) __preserves_regs(a,b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;

#endif
