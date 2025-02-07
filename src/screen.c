#include "resources.h"

// used in places where we define clipping boundaries
const byte clipBytes[] = {0,159,0,255};

// https://zx.remysharp.com/sprites/#sprite-editor

// https://github.com/benbaker76/Gfx2Next
// build/gfx2next ~/spacer.png -pal-std -pal-none -bitmap-y -bank-16k spacerTitle.nxi

void verticalLine(word x, word lowY, word highY, byte color) {
  selectLayer2Page(x >> 6);
  byte *pos = (byte *)((x % 64) * 256 + lowY);
  for(word y=lowY; y!=highY; ++y, ++pos) {
    *pos = color;
  }
}

void horizontalLine(word x, word y, word width, byte color) {
  selectLayer2Page(x >> 6);
  word xInPage = (x % 64);
  byte *pos = (byte *)(xInPage * 256 + y);

  for(word ex = x+width; x<=ex; ++x, pos += 256) {
    xInPage = (x % 64);
    if(xInPage==0) {
      selectLayer2Page(x >> 6);
      pos = (byte *)y;
    }
    *pos = color;
  }
}

void layer2fill(word x, word y, word width, word height, byte color) {
  word ex = x + width;
  word ey = y + height;
  for(word X=x; X!=ex; ++X) {
    verticalLine(X, y, ey, color);
  }
}

void layer2DmaFill(word x, word y, word width, word height, byte color) {
  word ex = x + width;
  byte endPage = ex >> 6;
  byte xInPage = x % 64;
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

void layer2box(word x, word y, word width, word height, byte color) {
  word ey = y + height;
  horizontalLine(x, y, width, color);
  horizontalLine(x, ey, width, color);
  ++y;
  verticalLine(x, y, ey, color);
  verticalLine(x + width, y, ey, color);
}

void layer2roundedBox(word x, word y, word width, word height, byte color) {
  word ey = y + height;
  verticalLine(x, y+1, ey, color);
  verticalLine(x+width, y+1, ey, color);
  horizontalLine(x+1, y, width-2, color);
  horizontalLine(x+1, ey, width-2, color);
}

void selectLayer2Page(byte page) __z88dk_fastcall {
  z80_outp(__IO_LAYER_2_CONFIG, 0x10 | page);
}

void layer2Clear(byte index) __z88dk_fastcall {
  for(byte page=0; page!=5; ++page) {
    selectLayer2Page(page);
    fillWithDma(0, 0x4000, index);
  }
}

void selectPalette(byte paletteMask) __z88dk_fastcall {
  ZXN_NEXTREGA(0x43, paletteMask << 4 | 1); // select palette, enable ulanext,
  ZXN_NEXTREG(0x40, 0); // start palette index
}

void fadePalette(const byte *restrict colors, word numBytes, byte shift) {
  ZXN_NEXTREG(0x40, 0); // start palette index

  for(word c=0; c<numBytes; c += 2) {
    byte msb = colors[c];
    byte lsb = colors[c+1];

    byte tr = msb >> 5;
    byte tg = (msb >> 2) & 7;
    byte tb = ((msb & 3) << 1) | (lsb & 1);

    byte r = shift<tr ? shift : tr;
    byte g = shift<tg ? shift : tg;
    byte b = shift<tb ? shift : tb;

    msb = r << 5 | g << 2 | b >> 1;
    ZXN_WRITE_REG(0x44, msb);

    lsb = b & 1;
    ZXN_WRITE_REG(0x44, lsb);
  }

  intrinsic_halt();
}

void fadePaletteDown(byte paletteMask, word numBytes) {
  selectPalette(paletteMask);

  byte existing[512];
  for(word f=0;f<256;f++) {
    ZXN_NEXTREGA(0x40, f); // start palette index

    word i = f*2;
    existing[i] = ZXN_READ_REG(0x41);
    existing[i+1] = ZXN_READ_REG(0x44) & 1;
  }

  for(byte shift=8; shift > 0; --shift) {
    fadePalette(existing, numBytes, shift-1);
  }
}

void fadePaletteUp(const byte *restrict colors, word numBytes, byte paletteMask, byte page) {
  selectPalette(paletteMask);

  byte previousMmu3 = ZXN_READ_MMU3();
  ZXN_WRITE_MMU3(page);

  for(byte shift=0; shift < 8; ++shift) {
    fadePalette(colors, numBytes, shift);
  }
  ZXN_WRITE_MMU3(previousMmu3);
}

void zeroPalette(byte palette, word length) {
  selectPalette(palette);
  
  ZXN_NEXTREG(0x40, 0);
  word bytes = length * 2;
  for(word f=0; f<bytes; ++f) {
    ZXN_NEXTREG(0x44, 0);
  }
}

void uploadPalette(const byte *restrict colors, word numBytes, byte palette, byte page) {
  selectPalette(palette);

  byte previousMmu3 = ZXN_READ_MMU3();
  ZXN_WRITE_MMU3(page);
  
  z80_outp(0x243b, 0x44);
  dmaMemoryToPort(colors, 0x253b, numBytes);
  ZXN_WRITE_MMU3(previousMmu3);
}

void layer2Plot(word x, byte y, byte color) {
  selectLayer2Page(x >> 6);
  byte *pos = (byte *)((x % 64) * 256 + y);
  *pos = color;
}

void setupLayers(byte mode) __z88dk_fastcall {
  ZXN_NEXTREGA(0x15, 0x23 | (mode << 2)); // 0'0'1'000'1'1 - Hires mode, index 127 on top, sprite window clipping over border, SLU priorities, over border, visible
}

void loadScreen(ResourceInfo *R[]) {
  ResourceInfo *screen = R[0];
  for(byte screenPage=18; screenPage<28; ++screenPage, ++screen) {
    ZXN_WRITE_MMU1(screen->page);
    ZXN_WRITE_MMU2(screenPage);
    decompressZX0((byte *)0x4000, screen->resource);
  }
}

void writeColourToIndex(const byte *colour, byte index) {
  ZXN_NEXTREGA(0x40, index);
  ZXN_NEXTREGA(0x44, *colour);
  ZXN_NEXTREGA(0x44, *colour+1);
}

void loadLevelScreen(byte level) __z88dk_fastcall {
  const LevelInfo *info = *(levelInfo+level);

  // flash jeffs white
  selectPalette(2);
  word white = 0x01FF;
  writeColourToIndex(&white, 128);
  writeColourToIndex(&white, 224);

  const word nonHudPaletteByteCount = 512-(HUD_COLOUR_COUNT * 2);
  fadePaletteDown(1, nonHudPaletteByteCount);

  loadScreen(info->screenArray);

  initHud(level);

  effectSiren();

  fadePaletteUp(info->paletteAsset->resource, nonHudPaletteByteCount, 1, info->paletteAsset->page);

  selectPalette(2);
  writeColourToIndex(info->jeffDark, 128);
  writeColourToIndex(info->jeffBright, 224);

  sprintf(textBuf, "ZONE %03d", level + 1);
  status(textBuf);
}

static byte shouldFadeTitle = 0;
void loadTitleScreen(void) __z88dk_fastcall {
  if(shouldFadeTitle) {
    fadePaletteDown(1, 512);
  } else {
    zeroPalette(1, 512);
  }
  ResourceInfo *titleScreenArray[] = SCREEN_ARRAY(title);
  loadScreen(titleScreenArray);
  if(shouldFadeTitle) {
    fadePaletteUp(R_title_nxi_nxp.resource, R_title_nxi_nxp.length, 1, R_title_nxi_nxp.page);
  } else {
    uploadPalette(R_title_nxi_nxp.resource, R_title_nxi_nxp.length, 1, R_title_nxi_nxp.page);
    shouldFadeTitle = 1;
  }
}

void loadInfoScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  ResourceInfo *screenArray[] = SCREEN_ARRAY(info);
  loadScreen(screenArray);
  fadePaletteUp(R_info_nxi_nxp.resource, R_info_nxi_nxp.length, 1, R_info_nxi_nxp.page);
}

void loadGameOverScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  ResourceInfo *screenArray[] = SCREEN_ARRAY(info);
  loadScreen(screenArray);
  fadePaletteUp(R_gameOverScreen_nxi_nxp.resource, R_gameOverScreen_nxi_nxp.length, 1, R_gameOverScreen_nxi_nxp.page);
}

void setFallbackColour(byte index) {
  ZXN_NEXTREGA(0x4A, index);
}

void setupScreen(void) __z88dk_fastcall {
  // https://wiki.specnext.dev/Layer_2
  z80_outp(__IO_LAYER_2_CONFIG, IO_123B_SHOW_LAYER_2 | IO_123B_ENABLE_LOWER_16K); // bank select 3, i.e. map all L2 and use offsets

  // Set res https://wiki.specnext.dev/Layer_2_Control_Register
  ZXN_NEXTREG(0x70, 0x10);

  // Clipping https://wiki.specnext.dev/Clip_Window_Layer_2_Register
  writeNextReg(0x18, clipBytes, CLIPBYTES_LEN);

  // L2 transparency index as 0
  ZXN_NEXTREG(0x14, 0);

  // ULAnext all ink
  ZXN_NEXTREG(0x42, 0xFF);

  setFallbackColour(0);

  // map ULA to page 10
  ZXN_NEXTREG(0x52, 10); 
  // map page 10 to 0x6000 instead of 0x4000
  ZXN_WRITE_MMU3(10);
}

void writeNextReg(byte reg, const char *bytes, byte len) {
  for(byte f=0; f!=len; ++f, ++bytes) {
    ZXN_WRITE_REG(reg, *bytes);
  }
}

void fillNextReg(byte reg, byte value, byte len) {
  for(byte i=0; i<len; ++i) {
    ZXN_WRITE_REG(reg, value);
  }
}
