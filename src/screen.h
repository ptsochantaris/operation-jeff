#ifndef _SCREEN_H_
#define _SCREEN_H_

#include "types.h"
#include "levelinfo.h"

#define CLIPBYTES_LEN 4

extern const byte clipBytes[];

void configLayer2(word writeThroughEnable) __z88dk_fastcall;
void layer2Clear(byte index) __z88dk_fastcall;
void uploadPalette(const ResourceInfo *restrict compressedPalette, word numBytes, byte palette);
void layer2Plot(word x, byte y, byte color);
void setupScreen(void) __z88dk_fastcall;
void setupLayers(byte mode) __z88dk_fastcall;

void selectPalette(byte paletteMask) __z88dk_fastcall;
void selectLayer2Page(byte page) __z88dk_fastcall;
void layer2box(word x, word y, word width, word height, byte color);
void layer2roundedBox(word x, word y, word width, word height, byte color);
void layer2fill(word x, word y, word width, word height, byte color);
void layer2circleFill(byte radius, word x, word y, byte colorTop, byte colorBottom, byte dividerY);
void layer2DmaFill(word x, word y, word width, word height, byte color);
void setFallbackColour(byte index);
void writeColourToIndex(const byte *colour, byte index);

void fadePaletteDown(byte paletteMask, word numBytes);
void fadePaletteUp(const ResourceInfo *restrict compressedPalette, word numBytes, byte paletteMask);
void zeroPalette(byte palette, word length);

void loadScreen(const LevelInfo *restrict info);

void writeNextReg(byte reg, const char *bytes, byte len);
void fillNextReg(byte reg, byte value, byte len);
void scrollLayer2(word x, byte y) __z88dk_callee;

#endif
