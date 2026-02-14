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
static byte cycle = 0;

static void updateCopper(void) {
    if(running) {
        copperControl(0x00); // stop copper, set prog address to zero
        running = 0;
    }

    if(foregroundColor == 0) {
        return;
    }

    cycle = 0;
    for(word y = 0; y < 52; ++y) {
        word top = y*4;
        stripe(foregroundColor, 0, top);
        stripe(backgroundColor, 0, top + 2);
    }

    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait for vblank

    copperControl(0xC0); // start copper from index 0, loop at vblank
    running = 1;
}

void copperCycle(void) __z88dk_fastcall {
    if(!running) {
        return;
    }
    
    word addressIndex = cycle*4;

    // restore stripe
    ZXN_NEXTREGA(REG_COPPER_DATA, foregroundColor);

    if(++cycle > 52) {
        cycle = 0;
    }

    addressIndex = cycle*4;

    // new white stripe
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
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
