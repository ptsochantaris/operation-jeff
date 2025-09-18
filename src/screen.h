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
void uploadPalette(const struct ResourceInfo *restrict compressedPalette, word numBytes, byte palette) __z88dk_callee;
void setupScreen(void) __z88dk_fastcall;
void setupLayers(byte mode) __z88dk_fastcall;

void layer2box(word x, word y, word width, word height, byte color) __z88dk_callee;
void layer2roundedBox(word x, word y, word width, word height, byte color) __z88dk_callee;
void layer2fill(word x, word y, word width, word height, byte color) __z88dk_callee;
void layer2circleFill(byte radius, word x, word y, byte colorTop, byte colorBottom, byte dividerY) __z88dk_callee;
void layer2DmaFill(word x, word y, word width, word height, byte color) __z88dk_callee;

void flashPaletteUp(void) __z88dk_fastcall;
void flashPaletteDown(void) __z88dk_fastcall;
void fadePaletteUp(const struct ResourceInfo *restrict compressedPalette, word numColours, byte paletteMask) __z88dk_callee;
void fadePaletteDown(byte paletteMask, byte framesPerFade, byte cycleUlaPalette) __z88dk_callee;

void loadScreen(const struct LevelInfo *restrict info) __z88dk_fastcall;

#endif
