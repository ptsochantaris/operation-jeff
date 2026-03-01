#ifndef _SCREEN_H_
#define _SCREEN_H_

#include "types.h"
#include "levelinfo.h"

#define CLIPBYTES_LEN 4
#define HEIGHTMAP_WIDTH 80
#define HEIGHTMAP_HEIGHT 64

extern const byte clipBytes[];

#define nonHudPaletteColourCount (256-HUD_COLOUR_COUNT)

void configLayer2(word writeThroughEnable) __z88dk_fastcall;
void layer2Clear(byte index) __z88dk_fastcall;
void uploadPalette(const struct ResourceInfo *restrict compressedPalette, word numBytes, byte palette) __z88dk_callee __smallc;
void setupScreen(void) __z88dk_fastcall;
void setupLayers(byte mode) __z88dk_fastcall;

void layer2box(word x, word y, word width, word height, byte color) __z88dk_callee __smallc;
void layer2roundedBox(word x, word y, word width, word height, byte color) __z88dk_callee __smallc;
void layer2circleFill(byte radius, word x, word y, byte colorTop, byte colorBottom, byte dividerY) __z88dk_callee __smallc;
void layer2DmaFill(word x, word y, word width, word height, byte color) __z88dk_callee __smallc;

void loadPaletteBuffer(const struct ResourceInfo *restrict compressedPalette) __z88dk_fastcall;
void stashPalette(byte paletteMask) __z88dk_fastcall;
void flashPaletteUp(void) __z88dk_fastcall;
void fadeToWhite(void) __z88dk_fastcall;
void flashPaletteDown(void) __z88dk_fastcall;
void fadeExistingPaletteUp(void) __z88dk_fastcall;
void fadePaletteUp(const struct ResourceInfo *restrict compressedPalette, byte paletteMask) __z88dk_callee __smallc;
void fadePaletteDown(byte paletteMask, byte framesPerFade, byte cycleUlaPalette) __z88dk_callee __smallc;

void loadScreen(const struct ResourceInfo *restrict slice) __z88dk_fastcall;
void printWithBackground(byte *text, word x, byte y, byte textColor, byte bgColor) __z88dk_callee __smallc;

#endif
