#include "resources.h"

#define CU_WAIT(ver,hor)  ((unsigned int)((((ver) & 0xff) << 8) + 0x80 + (((hor) & 0x3f) << 1) + (((ver) & 0x100) >> 8)))
#define CU_MOVE(reg,val)  ((unsigned int)((((val) & 0xff) << 8) + ((reg) & 0x7f)))
#define CU_NOP            ((unsigned int)0x0000)
#define CU_STOP           ((unsigned int)0xffff)

static word prog[] = {
    CU_WAIT(0,0),  CU_MOVE(REG_PALETTE_INDEX, 0), CU_MOVE(REG_PALETTE_VALUE_8, 0xe0),
    CU_WAIT(90,0), CU_MOVE(REG_PALETTE_INDEX, 0), CU_MOVE(REG_PALETTE_VALUE_8, 0),

    0xFF, 0xFF
};

void initCopper(void) {
    selectPalette(0);

    word copperProgLen = 7;
    byte *b = (byte *)&prog;
    for (byte j = 0; j < copperProgLen*2; ++j, ++b) {
        ZXN_NEXTREGA(REG_COPPER_DATA, *b);
    }

    ZXN_NEXTREG(REG_COPPER_CONTROL_H, 0xB0);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

void haltCopper(void) {
    ZXN_NEXTREG(REG_COPPER_CONTROL_H, 0);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}
