#include "resources.h"

extern const byte *bFont;
extern void ulaAttributeChar(const byte *restrict glyph, word x, byte y) __z88dk_callee __smallc;

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
    bzero((byte *)(ulaAttributes), 0x300);
}

void setupTitleLeds(void) __z88dk_fastcall {
    fillWithDma(ula, 0x1800 + 0x300, 0);

    resetGrayPalette();

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
    if(gray_offset == 2) {
        resetGrayPalette();
        return;
    }

    selectPalette(0);
    ZXN_NEXTREG(REG_PALETTE_VALUE_16, 0);
    ZXN_NEXTREG(REG_PALETTE_VALUE_16, 0);
    gray_offset -= 2;
    writeNextReg(REG_PALETTE_VALUE_16, ulaPalette+gray_offset, 16-gray_offset);
    writeNextReg(REG_PALETTE_VALUE_16, ulaPalette, gray_offset);
}

void resetGrayPalette(void) __z88dk_fastcall {
    selectPalette(0);
    ZXN_NEXTREG(REG_PALETTE_VALUE_16, 0);
    ZXN_NEXTREG(REG_PALETTE_VALUE_16, 0);
    gray_offset = 16;
    writeNextReg(REG_PALETTE_VALUE_16, ulaPalette, 16);
}

void printAttributes(const byte *restrict text, byte x, byte y) __z88dk_callee {
  byte C = *text;
  while(C != 0) {
    const byte *base = bFont + (6 * (C - 32));
    ulaAttributeChar(base, x, y);
    C = *(++text);
    x += 4;
  }
}

static byte statusCount = 0;

void clearStatus(void) __z88dk_fastcall {
    bzero((byte *)(ulaAttributes + 320), 160);
}

void status(const byte *text) __z88dk_fastcall {
    clearStatus();
    if(text) {
        resetGrayPalette();

        int x = 16 - (strlen(text) << 1);
        if(x<0) x=0;
        printAttributes(text, x, 10);
        statusCount = 16;
    } else {
        statusCount = 0;
    }
}

void updateStatus(void) __z88dk_fastcall {
    if(statusCount == 0) {
        return;
    }
    
    if(--statusCount == 0) {
        clearStatus();
    } else {
        cycleGrayPalette();
    }
}
