#include "base.h"

static void copperControl(byte code) __z88dk_fastcall {
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, code);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

static void stripe(byte colour, byte x, word y) __z88dk_callee {
    byte X = (x & 63) << 1;
    byte Y1 = y >> 15;
    byte Y2 = y & 0xFF;
    ZXN_NEXTREGA(REG_COPPER_DATA, 0x80 | X | Y1);
    ZXN_NEXTREGA(REG_COPPER_DATA, Y2); // wait

    ZXN_NEXTREG(REG_COPPER_DATA, 0x4A);
    ZXN_NEXTREGA(REG_COPPER_DATA, colour); // move
}

static void endOfProg(void) __z88dk_fastcall {
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait
}

static void flashTop(void) __z88dk_fastcall {
    stripe(0, 39, 0);
    stripe(0b11100000, 0, 255);
    endOfProg();
}

static void flashBottom(void) __z88dk_fastcall {
    stripe(0b11100000, 39, 223);
    stripe(0, 0, 255);
    endOfProg();
}

static void flashLeft(void) __z88dk_fastcall {
    for(word f=0;f<206;++f) {
        stripe(0b11100000, 39, f);
        stripe(0, 0, f+1);
    }
    endOfProg();
}

static void flashRight(void) __z88dk_fastcall {
    for(word f=0;f<206;++f) {
        stripe(0b11100000, 35, f);
        stripe(0, 38, f);
    }
    endOfProg();
}

void initCopper(void) __z88dk_fastcall {
    copperControl(0); // stop copper
    //flashTop();
    //flashBottom();
    //flashLeft();
    //flashRight();
    copperControl(0xC0); // start copper from index 0
}

// https://wiki.specnext.dev/Copper_Control_High_Byte
void haltCopper(void) __z88dk_fastcall {
    copperControl(0);
}
