#include "resources.h"

#define ula 0x4000
#define attributes ula + 0x1800
#define ulaEnd attributes + 0x300

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
    fillWithDma(attributes, 0x300, 0);
}

void setupTitleLeds(void) __z88dk_fastcall {
    fillWithDma(ula, 0x1800 + 0x300, 0);

    gray_offset = 2;
    cycleGrayPalette();

    // grayscale ULA attributes
    for(byte f=1;f!=9;++f) {
        word offset = attributes + (f-1) * 32;
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

static byte statusCount = 0;

extern const byte audio_zzzap;
extern const word audio_zzzap_len;

void status(const byte *text) __z88dk_fastcall {
    bzero((byte *)attributes + (10 * 32), (5 * 32));
    if(text) {
        playWithDma((word)&audio_zzzap, audio_zzzap_len, 0x90, 0);
        int x = 16 - (strlen(text) << 1);
        if(x<0) x=0;
        printAttributes(text, x, 10);
        statusCount = 16;
    }
}

void updateStatus(void) __z88dk_fastcall {
    if(statusCount == 0) return;
    if(--statusCount == 0) {
        status(NULL);
    } else {
        cycleGrayPalette();
    }
}

void printAttributes(const byte *restrict text, byte x, byte y) {
  byte C = *text;
  do {
    const byte *base = bFont + (6 * (C - 32));
    for(byte v=1; v!=6; ++v, ++base, ++y) {
      byte slice = *base;
      for(byte h=5; h != 8; ++h) {
        byte color = (slice & (1 << h)) ? v : 0;
        *(byte *)((0x5800 + x + 8 - h) + (y * 32)) = color;
      }
    }
    C = *(++text);
    x += 4;
    y -= 5;
  } while(C != 0);
}
