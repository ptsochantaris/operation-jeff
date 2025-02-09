#include "levelinfo.h"

LevelInfo titleInfo =    { { 0,0 }, { 0,0 }, 0, 0, 0, { SCREEN_ARRAY(title) },          R_title_nxp_zx0 };
LevelInfo infoInfo =     { { 0,0 }, { 0,0 }, 0, 0, 0, { SCREEN_ARRAY(info) },           R_info_nxp_zx0 };
LevelInfo gameOverInfo = { { 0,0 }, { 0,0 }, 0, 0, 0, { SCREEN_ARRAY(gameOverScreen) }, R_gameOverScreen_nxp_zx0 };

#define _LA  { { COLOR9(7, 1, 1) }, { COLOR9(3, 1, 1) },  40, 160, 100, { SCREEN_ARRAY(levelA) }, R_levelA_nxp_zx0 }
#define _LB  { { COLOR9(4, 7, 4) }, { COLOR9(0, 6, 0) },  50, 160,  90, { SCREEN_ARRAY(levelB) }, R_levelB_nxp_zx0 }
#define _LG  { { COLOR9(6, 6, 7) }, { COLOR9(5, 5, 6) },  60, 160,  80, { SCREEN_ARRAY(levelG) }, R_levelG_nxp_zx0 }
#define _LD  { { COLOR9(6, 6, 6) }, { COLOR9(2, 1, 1) },  70, 160,  78, { SCREEN_ARRAY(levelD) }, R_levelD_nxp_zx0 }
#define _LI  { { COLOR9(7, 6, 5) }, { COLOR9(6, 4, 1) },  80, 160,  76, { SCREEN_ARRAY(levelI) }, R_levelI_nxp_zx0 }
#define _LL  { { COLOR9(4, 6, 3) }, { COLOR9(3, 4, 2) },  90, 160,  74, { SCREEN_ARRAY(levelL) }, R_levelL_nxp_zx0 }
#define _LE  { { COLOR9(5, 6, 7) }, { COLOR9(3, 4, 5) }, 100, 160,  72, { SCREEN_ARRAY(levelE) }, R_levelE_nxp_zx0 }
#define _LN  { { COLOR9(7, 7, 4) }, { COLOR9(7, 6, 1) }, 110, 160,  70, { SCREEN_ARRAY(levelN) }, R_levelN_nxp_zx0 }
#define _LJ  { { COLOR9(7, 7, 7) }, { COLOR9(1, 2, 3) }, 120, 160,  68, { SCREEN_ARRAY(levelJ) }, R_levelJ_nxp_zx0 }
#define _LC  { { COLOR9(5, 7, 2) }, { COLOR9(1, 5, 1) }, 130, 160,  66, { SCREEN_ARRAY(levelC) }, R_levelC_nxp_zx0 }
#define _LK  { { COLOR9(7, 6, 6) }, { COLOR9(3, 2, 2) }, 130, 160,  64, { SCREEN_ARRAY(levelK) }, R_levelK_nxp_zx0 }
#define _LM  { { COLOR9(7, 2, 0) }, { COLOR9(2, 0, 1) }, 130, 160,  62, { SCREEN_ARRAY(levelM) }, R_levelM_nxp_zx0 }
#define _LF  { { COLOR9(7, 2, 4) }, { COLOR9(0, 0, 2) }, 130, 160,  60, { SCREEN_ARRAY(levelF) }, R_levelF_nxp_zx0 }
#define _LH  { { COLOR9(1, 1, 1) }, { COLOR9(0, 0, 0) }, 130, 160,  50, { SCREEN_ARRAY(levelH) }, R_levelH_nxp_zx0 }

LevelInfo levelInfo[] = {
    _LA, _LB, _LG, _LD, 
    _LI, _LL, _LE, _LN,
    _LJ, _LC, _LK, _LM, _LF, 
    _LH
};
