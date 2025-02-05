#include "levelinfo.h"

static LevelInfo _LA = { { COLOR9(7, 1, 1) }, { COLOR9(3, 1, 1) },  40, 160, 100, &R_levelA_0_nxi, &R_levelA_nxp };
static LevelInfo _LB = { { COLOR9(4, 7, 4) }, { COLOR9(0, 6, 0) },  50, 160,  90, &R_levelB_0_nxi, &R_levelB_nxp };
static LevelInfo _LG = { { COLOR9(6, 6, 7) }, { COLOR9(5, 5, 6) },  60, 160,  80, &R_levelG_0_nxi, &R_levelG_nxp };
static LevelInfo _LD = { { COLOR9(6, 6, 6) }, { COLOR9(2, 1, 1) },  70, 160,  70, &R_levelD_0_nxi, &R_levelD_nxp };
static LevelInfo _LI = { { COLOR9(7, 6, 5) }, { COLOR9(6, 4, 1) },  80, 160,  50, &R_levelI_0_nxi, &R_levelI_nxp };
static LevelInfo _LL = { { COLOR9(4, 6, 3) }, { COLOR9(3, 4, 2) },  90, 160,  60, &R_levelL_0_nxi, &R_levelL_nxp };
static LevelInfo _LE = { { COLOR9(5, 6, 7) }, { COLOR9(3, 4, 5) }, 100, 160,  55, &R_levelE_0_nxi, &R_levelE_nxp };
static LevelInfo _LJ = { { COLOR9(7, 7, 7) }, { COLOR9(1, 2, 3) }, 110, 160,  50, &R_levelJ_0_nxi, &R_levelJ_nxp };
static LevelInfo _LC = { { COLOR9(5, 7, 2) }, { COLOR9(1, 5, 1) }, 120, 160,  45, &R_levelC_0_nxi, &R_levelC_nxp };
static LevelInfo _LK = { { COLOR9(7, 6, 6) }, { COLOR9(3, 2, 2) }, 130, 160,  45, &R_levelK_0_nxi, &R_levelK_nxp };
static LevelInfo _LF = { { COLOR9(7, 2, 4) }, { COLOR9(0, 0, 2) }, 130, 160,  40, &R_levelF_0_nxi, &R_levelF_nxp };
static LevelInfo _LH = { { COLOR9(1, 1, 1) }, { COLOR9(0, 0, 0) }, 130, 160,  40, &R_levelH_0_nxi, &R_levelH_nxp };

LevelInfo *levelInfo[] = {
    &_LA, &_LB, &_LG, &_LD, 
    &_LI, &_LL, &_LE, 
    &_LJ, &_LC, &_LK, &_LF, 
    &_LH
};
