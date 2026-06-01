#include "base.h"

#define stripeX ((46 & 0x3F) << 1)

static void stripe(byte colour, word y) __z88dk_callee {
    // Set the colour up during the blanking of the line above `y`.
    word waitY = y - 1;
    byte Y1 = (waitY >> 8) & 1;
    byte Y2 = waitY & 0xFF;

    // wait
    ZXN_NEXTREGA(REG_COPPER_DATA, 0x80 | stripeX | Y1);
    ZXN_NEXTREGA(REG_COPPER_DATA, Y2);

    // move
    ZXN_NEXTREG(REG_COPPER_DATA, 0x4A);
    ZXN_NEXTREGA(REG_COPPER_DATA, colour);
}

static byte foreground1 = 0;
static byte foreground2 = 0;
static byte foreground3 = 0;
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

    switch(effect) {
        case 1:
            word lastCycle = ((STRIPECOUNT - 2) * 8 - 1);
            if(cycle == lastCycle) {
                direction = -8;
            } else if(cycle == 7) {
                direction = 8;
            }

            // new stripes
            cycle += direction;
            copperAddress(cycle);
            ZXN_NEXTREGA(REG_COPPER_DATA, foreground2);

            copperAddress(cycle + direction);
            ZXN_NEXTREGA(REG_COPPER_DATA, foreground1);

            copperAddress(cycle + direction + direction);
            ZXN_NEXTREGA(REG_COPPER_DATA, foreground2);
            return;

        case 2:
            word c = random16() % (STRIPECOUNT - 2);
            cycle = (c * 8) - 1;
            byte color = foreground2 + (random16() % 4);
            // new stripe
            copperAddress(cycle);
            ZXN_NEXTREGA(REG_COPPER_DATA, color);
            return;
    }
}

void copperForeground(byte colour1, byte colour2, byte colour3, byte effectType) __z88dk_callee {
    if(foreground1 == colour1 && foreground2 == colour2 && foreground3 == colour3 && effectType == effect) {
        return;
    }

    effect = effectType;
    foreground1 = colour1;
    foreground2 = colour2;
    foreground3 = colour3;
    
    copperStop();

    for(word y = 0; y < STRIPECOUNT; ++y) {
        word address = 3 + (y << 3);
        copperAddress(address);
        ZXN_NEXTREGA(REG_COPPER_DATA, foreground3);
        copperAddress(address+4);
        ZXN_NEXTREGA(REG_COPPER_DATA, foreground3);
    }
    
    // start copper from index 0, loop at vblank
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, 0xC0); // https://wiki.specnext.dev/Copper_Control_High_Byte
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);

    running = 1;
}

void copperShutdown(void) __z88dk_fastcall {
    if(!running) return;

    // restore stripe
    copperAddress(cycle);
    ZXN_NEXTREGA(REG_COPPER_DATA, 0);

    copperStop();
    
    foreground1 = 0;
    foreground2 = 0;
    foreground3 = 0;
    cycle = 7;
    direction = 8;
    running = 0;

    ZXN_NEXTREG(0x4a, 0);
}

void copperInit(void) __z88dk_fastcall {
    copperStop();

    ZXN_NEXTREG(0x64, 34); // offset copper by 34 pixels up from ULA zero

    for(word y = 0; y < STRIPECOUNT; ++y) {
        word top = y*STRIPESIZE+22;
        stripe(0, top);
        stripe(0, top + (STRIPESIZE / 2));
    }

    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait for vblank
}
