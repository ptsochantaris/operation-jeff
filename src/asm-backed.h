#ifndef _ASM_BACKED_H_
#define _ASM_BACKED_H_

void decompressZX0(byte *src, byte *dst) __z88dk_callee __smallc;
void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
int random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;

void updateSprite(struct sprite_info *restrict s) __preserves_regs(iyh,iyl) __z88dk_fastcall;

void selectPalette(byte paletteMask) __preserves_regs(b,c,d,e,h,iyh,iyl) __z88dk_fastcall;
void layer2Plot(word x, byte y, byte color) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void layer2HorizonalLine(word x, word y, word width, byte color) __z88dk_callee __smallc;
void layer2VerticalLine(word x, word topY, word bottomY, byte color) __z88dk_callee __smallc;
void selectLayer2Page(byte page) __preserves_regs(b,c,d,h,iyh,iyl) __z88dk_fastcall;
void layer2StashPalette(byte *restrict buffer) __preserves_regs(iyh,iyl) __z88dk_fastcall;

void print(byte *text, word x, byte y, byte textColor, byte bgColor) __z88dk_callee __smallc;
void printNoBackground(byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;
void printSidewaysNoBackground(byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;
void printAttributes(byte *text, byte x, byte y) __z88dk_callee __smallc;

#endif
