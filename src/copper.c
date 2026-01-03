#include "base.h"

static void copperControl(byte code) __z88dk_fastcall {
    // https://wiki.specnext.dev/Copper_Control_High_Byte
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, code);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

static void stripe(byte colour, byte x, word y) __z88dk_callee {
    byte X = (x & 63) << 1;
    byte Y1 = y >> 15;
    byte Y2 = y & 0xFF;

    // wait
    ZXN_NEXTREGA(REG_COPPER_DATA, 0x80 | X | Y1);
    ZXN_NEXTREGA(REG_COPPER_DATA, Y2);

    // move
    ZXN_NEXTREG(REG_COPPER_DATA, 0x4A);
    ZXN_NEXTREGA(REG_COPPER_DATA, colour);
}

static byte foregroundColor = 0xFF;
static byte backgroundColor = 0xFF;
static byte running = 1;

static void updateCopper(void) {
    if(running) {
        copperControl(0x00); // stop copper, set prog address to zero
        running = 0;
    }

    if(foregroundColor == 0) {
        return;
    }

    for(word y = 0; y < 208; y += 4) {
        stripe(foregroundColor, 0, y);
        stripe(backgroundColor, 0, y + 2);
    }
    // max: 247?

    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait for vblank

    copperControl(0xC0); // start copper from index 0, loop at vblank
    running = 1;
}

void copperForeground(byte color) __z88dk_fastcall {
    if(foregroundColor == color) {
        return;
    }

    foregroundColor = color;
    updateCopper();
}

void copperBackground(byte color) __z88dk_fastcall {
    if(color == backgroundColor) {
        return;
    }

    setFallbackColour(color);
    backgroundColor = color;
    if(running) {
        updateCopper();
    }
}

void copperReset(void) __z88dk_fastcall {
    copperForeground(0);
    copperBackground(0);
}
