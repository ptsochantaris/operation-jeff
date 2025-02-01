#include "resources.h"

extern const byte *bFont;

static const byte ulaPalette[] = {
  COLOR9(1, 1, 1),
  COLOR9(3, 3, 3),
  COLOR9(5, 5, 5),
  COLOR9(7, 7, 7),
  COLOR9(7, 7, 7),
  COLOR9(5, 5, 5),
  COLOR9(3, 3, 3),
  COLOR9(1, 1, 1),
  COLOR9(0, 0, 0)
};

static byte gray_offset = 2;

void ulaAttributeClear(void) __z88dk_fastcall {
    fillWithDma(ulaAttributes, 0x300, 0);
}

void setupTitleLeds(void) __z88dk_fastcall {
    fillWithDma(ula, 0x1800 + 0x300, 0);

    gray_offset = 2;
    cycleGrayPalette();

    // grayscale ULA attributes
    for(byte f=1;f!=9;++f) {
        word offset = ulaAttributes + (f-1) * 32;
        fillWithDma(offset, 32, 9 - f);
        fillWithDmaRepeat(offset + 256, 32, f, 2, 256);
    }

    // horizontal stripes on ULA
    for(word f=0; f!=8; f+=2) {
        fillWithDmaRepeat(f * 256 + ula, 256, 0x55, 3, 2048);
    }
}

void cycleGrayPalette(void) __z88dk_fastcall {
    gray_offset -= 2;
    if(gray_offset == 0) {
        gray_offset = 16;
    }

    selectPalette(0);

    ZXN_NEXTREGA(0x44, 0);
    ZXN_NEXTREGA(0x44, 0);

    for(byte f=gray_offset;f!=16;++f) {
        ZXN_NEXTREGA(0x44, *(ulaPalette+f));
    }

    for(byte f=0;f!=gray_offset;++f) { // leaving zero untouched
        ZXN_NEXTREGA(0x44, *(ulaPalette+f));
    }

    ZXN_NEXTREGA(0x41, 0xFC); // yellow for leds
}

void printAttributes(const byte *restrict text, byte x, byte y) {
  byte C = *text;
  do {
    const byte *base = bFont + (6 * (C - 32));
    for(byte v=1; v!=6; ++v, ++base, ++y) {
      byte slice = *base;
      for(byte h=5; h != 8; ++h) {
        if(slice & (1 << h)) {
            *(byte *)((ulaAttributes + x + 8 - h) + (y * 32)) = v;
        }
      }
    }
    C = *(++text);
    x += 4;
    y -= 5;
  } while(C != 0);
}

static byte statusCount = 0;

void status(const byte *text, byte effect) {
    fillWithDma(ulaAttributes + 320, 160, 0);
    if(text) {
        int x = 16 - (strlen(text) << 1);
        if(x<0) x=0;
        printAttributes(text, x, 10);
        statusCount = 16;
    }
    switch(effect) {
        case 1:
            effectZap();
            break;
        case 2:
            effectSiren();
            break;
    }
}

void updateStatus(void) __z88dk_fastcall {
    if(statusCount == 0) return;
    if(--statusCount == 0) {
        status(NULL, 0);
    } else {
        cycleGrayPalette();
    }
}
