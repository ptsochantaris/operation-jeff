#include "base.h"

static void copperControl(byte code) __z88dk_fastcall {
    // https://wiki.specnext.dev/Copper_Control_High_Byte
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, code);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

static void copperAddress(word address) __z88dk_fastcall {
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, 0xC0 | (address >> 8));
    ZXN_NEXTREGA(REG_COPPER_CONTROL_L, address & 0xFF);
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

static byte foregroundColor = 0;
static byte effect = 0;
static byte running = 0;
static word cycle = 7;
static signed char direction = 8;

#define STRIPECOUNT 60
#define STRIPESIZE 4

void copperCycle(void) __z88dk_fastcall {
    if(!running) {
        return;
    }

    // restore stripe
    copperAddress(cycle);
    ZXN_NEXTREGA(REG_COPPER_DATA, 0);

    byte color;
    switch(effect) {
        case 1:
            word lastCycle = ((STRIPECOUNT - 2) * 8 - 1);
            if(cycle == lastCycle) {
                direction = -8;
            } else if(cycle == 7) {
                direction = 8;
            }
            cycle += direction;
            color = 0x92;
            break;
        case 2:
            word c = random16() % (STRIPECOUNT-2);
            cycle = (c * 8) - 1;
            color = 0xFC + (random16() % 4);
            break;
    }

    // new stripe
    copperAddress(cycle);
    ZXN_NEXTREGA(REG_COPPER_DATA, color);
}

void copperForeground(byte colour, byte effectType) __z88dk_callee {
    if(foregroundColor == colour) {
        return;
    }

    effect = effectType;
    foregroundColor = colour;
    copperControl(0x00); // stop copper, set prog address to zero
    for(word y = 0; y < STRIPECOUNT; ++y) {
        copperAddress(3 + (y << 3));
        ZXN_NEXTREGA(REG_COPPER_DATA, colour);
    }
    copperControl(0xC0); // start copper from index 0, loop at vblank
    running = 1;
}

void copperShutdown(void) __z88dk_fastcall {
    if(!running) return;

    // restore stripe
    copperAddress(cycle);
    ZXN_NEXTREGA(REG_COPPER_DATA, 0);

    copperControl(0x00); // stop copper, set prog address to zero
    
    foregroundColor = 0;
    cycle = 7;
    direction = 8;
    running = 0;

    ZXN_NEXTREG(0x4a, 0);
}

void copperInit(void) __z88dk_fastcall {
    copperControl(0x00); // stop copper, set prog address to zero

    ZXN_NEXTREG(0x64, 34); // offset copper by 34 pixels up from ULA zero

    for(word y = 0; y < STRIPECOUNT; ++y) {
        word top = y*STRIPESIZE+22;
        stripe(0, 0, top);
        stripe(0, 0, top + (STRIPESIZE / 2));
    }

    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait for vblank
}
