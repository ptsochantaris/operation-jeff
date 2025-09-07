#include "resources.h"

const word nonHudPaletteByteCount = 512-(HUD_COLOUR_COUNT * 2);

// used in places where we define clipping boundaries
const byte clipBytes[] = {0,159,0,255};

// https://zx.remysharp.com/sprites/#sprite-editor

// https://github.com/benbaker76/Gfx2Next
// build/gfx2next ~/spacer.png -pal-std -pal-none -bitmap-y -bank-16k spacerTitle.nxi

extern void layer2HorizonalLine(word x, word y, word width, byte color) __z88dk_callee __smallc;
extern void layer2VerticalLine(word x, word topY, word bottomY, byte color) __z88dk_callee __smallc;
extern void selectLayer2Page(byte page) __preserves_regs(b,c,d,h,iyh,iyl) __z88dk_fastcall;
extern void layer2StashPalette(byte *restrict buffer) __preserves_regs(iyh,iyl) __z88dk_fastcall;

void layer2fill(word x, word y, word width, word height, byte color) __z88dk_callee {
  word ex = x + width;
  word ey = y + height;
  for(word X=x; X!=ex; ++X) {
    layer2VerticalLine(X, y, ey, color);
  }
}

void layer2DmaFill(word x, word y, word width, word height, byte color) __z88dk_callee {
  word ex = x + width;
  byte endPage = ex >> 6;
  byte xInPage = x & 0x3F;
  word bottomLeft = xInPage * 256 + y;
  byte page = x >> 6;

  selectLayer2Page(page);
  if(page >= endPage) {
   fillWithDmaRepeat(bottomLeft, height, color, width, 256);
  } else {
    fillWithDmaRepeat(bottomLeft, height, color, 64-xInPage, 256);
    --endPage;
    while(1) {
      selectLayer2Page(++page);
      if(page == endPage) {
        word endXInPage = (ex - (page * 64));
        fillWithDmaRepeat(y, height, color, endXInPage, 256);
        return;
      } else {
        fillWithDmaRepeat(y, height, color, 64, 256);
      }
    }
  }
}

void layer2box(word x, word y, word width, word height, byte color) __z88dk_callee {
  word ey = y + height;
  layer2HorizonalLine(x, y, width, color);
  layer2HorizonalLine(x, ey, width, color);
  ++y;
  layer2VerticalLine(x, y, ey, color);
  layer2VerticalLine(x + width, y, ey, color);
}

void layer2roundedBox(word x, word y, word width, word height, byte color) __z88dk_callee {
  word ey = y + height;
  layer2VerticalLine(x, y+1, ey, color);
  layer2VerticalLine(x+width, y+1, ey, color);
  layer2HorizonalLine(x+1, y, width-2, color);
  layer2HorizonalLine(x+1, ey, width-2, color);
}

void layer2Clear(byte index) __z88dk_fastcall {
  for(byte page=0; page!=5; ++page) {
    selectLayer2Page(page);
    fillWithDma(0, 0x4000, index);
  }
}

void selectPalette(byte paletteMask) __z88dk_fastcall {
  ZXN_NEXTREGA(0x43, paletteMask << 4 | 1); // select palette, enable ulanext,
  ZXN_NEXTREG(REG_PALETTE_INDEX, 0); // start palette index
}

static byte paletteBuffer[512];

void loadPaletteBuffer(const struct ResourceInfo *restrict compressedPalette) __z88dk_callee {
  byte previousMmu3 = ZXN_READ_MMU3();
  ZXN_WRITE_MMU3(compressedPalette->page);
  decompressZX0(paletteBuffer, (byte *)(compressedPalette->resource));
  ZXN_WRITE_MMU3(previousMmu3);
}

void stashPalette(byte paletteMask) __z88dk_fastcall {
  selectPalette(paletteMask);
  layer2StashPalette(paletteBuffer);
}

void shiftPalette(word numBytes, byte shift, byte bright) __z88dk_callee {
  ZXN_NEXTREG(REG_PALETTE_INDEX, 0); // start palette index

  byte r, g, b, col;
  byte *pairEnd = paletteBuffer+numBytes;
  for(byte *pairs = paletteBuffer; pairs != pairEnd; ++pairs) {
    col = *pairs;

    r = col >> 5;
    g = (col >> 2) & 7;
    b = ((col & 3) << 1) | (*(++pairs) & 1);

    if(bright) {
      if(shift > r) r = shift;
      if(shift > g) g = shift;
      if(shift > b) b = shift;
    } else {
      if(shift < r) r = shift;
      if(shift < g) g = shift;
      if(shift < b) b = shift;
    }

    col = r << 5 | g << 2 | b >> 1;
    ZXN_WRITE_REG(REG_PALETTE_VALUE_16, col);

    col = b & 1;
    ZXN_WRITE_REG(REG_PALETTE_VALUE_16, col);
  }

  intrinsic_halt();
}

void flashPaletteUp(void) __z88dk_fastcall {
  stashPalette(1);
  shiftPalette(nonHudPaletteByteCount, 2, 1);
  shiftPalette(nonHudPaletteByteCount, 5, 1);
  shiftPalette(nonHudPaletteByteCount, 6, 1);
}

void flashPaletteDown(void) __z88dk_fastcall {
  for(byte shift=8; shift > 0; --shift) {
    shiftPalette(nonHudPaletteByteCount, shift-1, 1);
  }
}

void _fadePaletteDown(byte paletteMask, word numBytes, byte framesPerFade, byte cycleUlaPalette) __z88dk_callee {
  stashPalette(paletteMask);

  for(byte shift=8; shift > 0; --shift) {
    shiftPalette(numBytes, shift-1, 0);

    if(cycleUlaPalette) {
      cycleGrayPalette();
      selectPalette(paletteMask);
    }

    for(byte i=0; i!=framesPerFade; ++i) {
      intrinsic_halt();
    }
  }
}

void fadePaletteDown(byte paletteMask, word numBytes) __z88dk_callee {
  _fadePaletteDown(paletteMask, numBytes, 1, 0);
}

void fadePaletteDownSlow(byte paletteMask, word numBytes) __z88dk_callee {
  _fadePaletteDown(paletteMask, numBytes, 8, 1);
}

void fadePaletteUp(const struct ResourceInfo *restrict compressedPalette, word numBytes, byte paletteMask) __z88dk_callee {
  selectPalette(paletteMask);
  loadPaletteBuffer(compressedPalette);

  for(byte shift=0; shift != 8; ++shift) {
    shiftPalette(numBytes, shift, 0);
    intrinsic_halt(); // extra delay
  }
}

void zeroPalette(byte palette, word length) __z88dk_callee {
  selectPalette(palette);
  
  ZXN_NEXTREG(REG_PALETTE_INDEX, 0);
  word bytes = length * 2;
  for(word f=0; f != bytes; ++f) {
    ZXN_NEXTREG(REG_PALETTE_VALUE_16, 0);
  }
}

void uploadPalette(const struct ResourceInfo *restrict compressedPalette, word numBytes, byte palette) __z88dk_callee {
  selectPalette(palette);
  loadPaletteBuffer(compressedPalette);
  
  z80_outp(0x243b, REG_PALETTE_VALUE_16);
  dmaMemoryToPort(paletteBuffer, 0x253b, numBytes);
}

void scrollLayer2(word x, byte y) __z88dk_callee {
  ZXN_NEXTREGA(0x71, x >> 8);
  ZXN_NEXTREGA(0x16, x & 0xFF);
  ZXN_NEXTREGA(0x17, y);
}

void setupLayers(byte mode) __z88dk_fastcall {
  ZXN_NEXTREGA(0x15, 0x23 | (mode << 2)); // 0'0'1'000'1'1 - Hires mode, index 127 on top, sprite window clipping over border, SLU priorities, over border, visible
}

void loadScreen(const struct LevelInfo *restrict info) __z88dk_callee {  
  struct ResourceInfo *slice = info->screens;
  for(byte page=18; page!=28; ++page, ++slice) {
    ZXN_WRITE_MMU2(page);
    ZXN_WRITE_MMU1(slice->page);
    decompressZX0((byte *)0x4000, (byte *)slice->resource);
  }
}

void readColourFromIndex(byte *colour, byte index) __z88dk_callee {
  ZXN_NEXTREGA(REG_PALETTE_INDEX, index);
  *colour = ZXN_READ_REG(REG_PALETTE_VALUE_8);
  *(colour+1) = ZXN_READ_REG(REG_PALETTE_VALUE_16);
}

void writeColourToIndex(const byte *colour, byte index) __z88dk_callee {
  ZXN_NEXTREGA(REG_PALETTE_INDEX, index);
  ZXN_NEXTREGA(REG_PALETTE_VALUE_16, *colour);
  ZXN_NEXTREGA(REG_PALETTE_VALUE_16, *colour+1);
}

void setFallbackColour(byte index) __z88dk_callee {
  ZXN_NEXTREGA(0x4A, index);
}

void configLayer2(word writeThroughEnable) __z88dk_fastcall {
  // https://wiki.specnext.dev/Layer_2
  z80_outp(__IO_LAYER_2_CONFIG, IO_123B_SHOW_LAYER_2 | writeThroughEnable);
}

void setupScreen(void) __z88dk_fastcall {
  configLayer2(1);

  // Set res https://wiki.specnext.dev/Layer_2_Control_Register
  ZXN_NEXTREG(0x70, 0x10);

  // Clipping https://wiki.specnext.dev/Clip_Window_Layer_2_Register
  writeNextReg(0x18, clipBytes, CLIPBYTES_LEN);

  // L2 transparency index as 0
  ZXN_NEXTREG(0x14, 0);

  // ULAnext ink mode
  ZXN_NEXTREG(REG_ULANEXT_PALETTE_FORMAT, 127);

  // map ULA to page 10
  ZXN_NEXTREG(0x52, 10); 
}

 const byte corner1px[] = { 1 };
 const byte corner2px[] = { 1, 2 };
 const byte corner3px[] = { 2, 2, 3 };
 const byte corner4px[] = { 2, 3, 3, 4 };
 const byte corner5px[] = { 2, 4, 4, 5, 5 };
 const byte corner6px[] = { 2, 4, 5, 5, 6, 6 };
 const byte corner7px[] = { 2, 4, 5, 6, 6, 7, 7 };
 const byte corner8px[] = { 2, 4, 5, 6, 7, 7, 8, 8 };

 const byte *corners[] = { 
  corner1px, 
  corner2px, 
  corner3px, 
  corner4px, 
  corner5px, 
  corner6px, 
  corner7px, 
  corner8px
};

void layer2circleFill(byte radius, word x, word y, byte colorTop, byte colorBottom, byte dividerY) __z88dk_callee {
  const byte *widths = corners[radius-1];
  word mid = x + radius;
  word ey = y + (radius << 1) - 1;
  for(word c = 0; c != radius; ++c) {
    word w = *(widths+c);
    word l = mid-w;
    word W = w << 1;
    word Y = y+c;
    layer2HorizonalLine(l, Y, W, (Y>dividerY) ? colorBottom : colorTop);
    Y = ey-c;
    layer2HorizonalLine(l, Y, W, (Y>dividerY) ? colorBottom : colorTop);
  }
}
