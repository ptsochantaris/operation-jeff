#include "resources.h"

const static word prog[] = {
    CU_WAIT(20,0),  
    CU_MOVE(REG_PALETTE_INDEX, 1), 
    CU_MOVE(REG_PALETTE_VALUE_8, 0xff),
    
    CU_WAIT(100,0), 
    CU_MOVE(REG_PALETTE_INDEX, 1), 
    CU_MOVE(REG_PALETTE_VALUE_8, 0),

    CU_WAIT(400,0)
};

void initCopper(void) {
    word copperProgLen = 7;
    const byte *e = prog + (copperProgLen * 2);
    for (const byte *b = prog; b < e; ++b) {
        ZXN_NEXTREGA(REG_COPPER_DATA, *b);
    }

    ZXN_NEXTREG(REG_COPPER_CONTROL_H, 0xB0);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}

void haltCopper(void) {
    ZXN_NEXTREG(REG_COPPER_CONTROL_H, 0);
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);
}
