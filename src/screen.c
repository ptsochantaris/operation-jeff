#include "resources.h"

// used in places where we define clipping boundaries
const byte clipBytes[] = {0,159,0,255};

// https://zx.remysharp.com/sprites/#sprite-editor

// https://github.com/benbaker76/Gfx2Next
// build/gfx2next ~/Desktop/spacer.png -pal-std -pal-none -bitmap-y -bank-16k spacerTitle.nxi

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

void uploadPalette(const byte *restrict colors, word numBytes, byte palette, byte page) {
  selectPalette(palette);

  byte previousPage = ZXN_READ_MMU0();
  ZXN_WRITE_MMU0(page);
  
  z80_outp(0x243b, 0x44);
  dmaMemoryToPort(colors, 0x253b, numBytes);
  
  ZXN_WRITE_MMU0(previousPage);
}

void layer2Plot(word x, byte y, byte color) {
  selectLayer2Page(x >> 6);
  byte *pos = (byte *)((x % 64) * 256 + y);
  *pos = color;
}

void setupLayers(byte mode) __z88dk_fastcall {
  ZXN_NEXTREGA(0x15, 0x23 | (mode << 2)); // 0'0'1'000'1'1 - Hires mode, index 127 on top, sprite window clipping over border, SLU priorities, over border, visible
}

void loadScreen(byte page, const byte *restrict palette) {
  uploadPalette(palette, 512, 1, 150); // L2 first palette

  byte previousPage0 = ZXN_READ_MMU0();
  byte previousPage1 = ZXN_READ_MMU1();

  for(byte bank=0; bank!=5; ++bank) {
    selectLayer2Page(bank);
    ZXN_WRITE_MMU0(page++);
    ZXN_WRITE_MMU1(page++);
    if(bank==0) {
      dmaMemoryToMemory((const byte *)0, (byte *)0, 0x4000);
    } else {
      dmaRepeat();
    }
  }

  ZXN_WRITE_MMU0(previousPage0);
  ZXN_WRITE_MMU1(previousPage1);
}

extern const byte level_a_palette;

extern const byte default_palette;

void writeColourToIndex(const byte *colour, byte index) {
  ZXN_NEXTREGA(0x40, index);
  ZXN_NEXTREGA(0x44, *colour);
  ZXN_NEXTREGA(0x44, *colour+1);
}

void loadLevelScreen(byte level) __z88dk_fastcall {
  const byte *palette = &level_a_palette + level * 512;
  loadScreen(49 + (level * 10), palette);

  uploadPalette((const byte *)&default_palette, 512, 2, 150); // sprite first palette
  writeColourToIndex(darkJeffColor(level), 128);
  writeColourToIndex(brightJeffColor(level), 224);

  initHud(level);

  sprintf(textBuf, "ZONE %03d", level + 1);
  status(textBuf);
}

extern const byte title_palette;
void loadTitleScreen(void) __z88dk_fastcall {
  loadScreen(29, &title_palette);
}

extern const byte info_palette;
void loadInfoScreen(void) __z88dk_fastcall {
  loadScreen(39, &info_palette);
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

  // map ULA to $4000
  ZXN_NEXTREG(0x52, 10); 
}

void writeNextReg(byte reg, const char *bytes, byte len) {
  for(byte f=0; f<len; ++f, ++bytes) {
    ZXN_WRITE_REG(reg, *bytes);
  }
}
