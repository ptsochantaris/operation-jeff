#ifndef _GRAPHICS_H_
#define _GRAPHICS_H_

#include "types.h"

void selectPalette(byte paletteMask) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void layer2Plot(word x, byte y, byte color) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void layer2HorizonalLine(word x, word y, word width, byte color) __z88dk_callee __smallc;
void layer2VerticalLine(word x, word topY, word bottomY, byte color) __z88dk_callee __smallc;
void selectLayer2Page(byte page) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void layer2StashPalette(byte *restrict buffer) __preserves_regs(iyh,iyl) __z88dk_fastcall;
void setFallbackColour(byte index) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void readColourFromIndex(byte *colour, byte index) __preserves_regs(d,e,iyh,iyl) __z88dk_callee __smallc;
void writeColourToIndex(const byte *colour, byte index) __preserves_regs(d,e,iyh,iyl) __z88dk_callee __smallc;
void zeroPalette(byte palette) __preserves_regs(c,d,h,l,iyh,iyl) __z88dk_fastcall;
void scrollLayer2(word x, byte y) __preserves_regs(b,c,iyh,iyl) __z88dk_callee __smallc;
void layer2fill(word x, word y, word width, word height, byte color) __z88dk_callee __smallc;

void updateSprite(struct sprite_info *restrict s) __z88dk_fastcall;
void hideSprite(byte index) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;

void scrollTilemap(word x, byte y) __preserves_regs(b,c,iyh,iyl) __z88dk_callee __smallc;

void setHudBackground(word color) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;

void print(byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;
void printSideways(byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;
void printAttributes(byte *text, byte x, byte y) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;

#endif
