#include "base.h"

static void copperControl(byte code) __z88dk_fastcall {
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, code);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

static void copperBar(byte y, byte step) __z88dk_callee __smallc {
        byte shades[] = {
        0,
        0b01001001,
        0b01101101,
        0b10010010,
        0b10110110,
        0b11011011,
        0b11111111,
        0b11011011,
        0b10010010,
        0b01101101,
        0b01001001,
        0
    };

    for(byte shadeIndex=0; shadeIndex != 12; ++shadeIndex) {
        ZXN_NEXTREG(REG_COPPER_DATA, 0x80);
        ZXN_NEXTREGA(REG_COPPER_DATA, y); // wait

        ZXN_NEXTREG(REG_COPPER_DATA, 0x4A);
        ZXN_NEXTREGA(REG_COPPER_DATA, shades[shadeIndex]); // move

        y += step;
    }
    ZXN_NEXTREG(REG_COPPER_DATA, 0x81);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait
}

void initCopper(void) __z88dk_fastcall {
    copperControl(0); // stop copper
    copperBar(0, 4);
    copperControl(0xC0); // start copper from index 0
}

// https://wiki.specnext.dev/Copper_Control_High_Byte
void haltCopper(void) __z88dk_fastcall {
    copperControl(0);
}
