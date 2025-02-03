#include "levelinfo.h"

static LevelInfo _LA = { { COLOR9(7, 1, 1) }, { COLOR9(3, 1, 1) },  40, 160, 100,  49,  0 };
static LevelInfo _LB = { { COLOR9(4, 7, 4) }, { COLOR9(0, 6, 0) },  50, 160,  90,  59,  1 };
static LevelInfo _LG = { { COLOR9(6, 6, 7) }, { COLOR9(5, 5, 6) },  60, 160,  80, 109,  6 };
static LevelInfo _LD = { { COLOR9(6, 6, 6) }, { COLOR9(2, 1, 1) },  70, 160,  70,  79,  3 };
static LevelInfo _LI = { { COLOR9(7, 6, 5) }, { COLOR9(6, 4, 1) },  80, 160,  50, 129,  8 };
static LevelInfo _LL = { { COLOR9(4, 6, 3) }, { COLOR9(3, 4, 2) },  90, 160,  60, 159, 11 };
static LevelInfo _LE = { { COLOR9(5, 6, 7) }, { COLOR9(3, 4, 5) }, 100, 160,  55,  89,  4 };
static LevelInfo _LJ = { { COLOR9(7, 7, 7) }, { COLOR9(1, 2, 3) }, 110, 160,  50, 139,  9 };
static LevelInfo _LC = { { COLOR9(5, 7, 2) }, { COLOR9(1, 5, 1) }, 120, 160,  45,  69,  2 };
static LevelInfo _LK = { { COLOR9(7, 6, 6) }, { COLOR9(3, 2, 2) }, 130, 160,  45, 149, 10 };
static LevelInfo _LF = { { COLOR9(7, 2, 4) }, { COLOR9(0, 0, 2) }, 130, 160,  40,  99,  5 };
static LevelInfo _LH = { { COLOR9(1, 1, 1) }, { COLOR9(0, 0, 0) }, 130, 160,  40, 119,  7 };

LevelInfo *levelInfo[] = {
    &_LA, &_LB, &_LG, &_LD, 
    &_LI, &_LL, &_LE, 
    &_LJ, &_LC, &_LK, &_LF, 
    &_LH
};
