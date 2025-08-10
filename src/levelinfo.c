#include "levelinfo.h"
#include "assets.h"

//      jeffBright           jeffDark             fontDark           killsRequired screens+paletteAsset  heightmapAsset
//                                                                        difficultyStep
//                                                                             initialGenerationPeriod
struct LevelInfo levelInfo[] = {
    { { COLOR9(7, 1, 1) }, { COLOR9(3, 1, 1) }, { COLOR9(7, 7, 7) },  40, 150, 90, SCREEN_ARRAY(levelA), R_heightmapA_hm_zx0 }, // 1
    { { COLOR9(7, 7, 7) }, { COLOR9(5, 5, 5) }, { COLOR9(2, 2, 2) },  45, 150, 86, SCREEN_ARRAY(levelO), R_heightmapO_hm_zx0 }, // 2
    { { COLOR9(4, 7, 4) }, { COLOR9(0, 6, 0) }, { COLOR9(7, 7, 7) },  50, 150, 82, SCREEN_ARRAY(levelB), R_heightmapB_hm_zx0 }, // 3
    { { COLOR9(6, 6, 7) }, { COLOR9(5, 5, 6) }, { COLOR9(7, 7, 7) },  60, 150, 80, SCREEN_ARRAY(levelG), R_heightmapG_hm_zx0 }, // 4
    { { COLOR9(6, 6, 6) }, { COLOR9(2, 1, 1) }, { COLOR9(7, 7, 7) },  70, 160, 78, SCREEN_ARRAY(levelD), R_heightmapD_hm_zx0 }, // 5
    { { COLOR9(7, 6, 5) }, { COLOR9(6, 4, 1) }, { COLOR9(7, 7, 7) },  75, 160, 78, SCREEN_ARRAY(levelI), R_heightmapI_hm_zx0 }, // 6
    { { COLOR9(4, 6, 3) }, { COLOR9(3, 4, 2) }, { COLOR9(7, 7, 7) },  90, 160, 74, SCREEN_ARRAY(levelL), R_heightmapL_hm_zx0 }, // 7
    { { COLOR9(5, 6, 7) }, { COLOR9(3, 4, 5) }, { COLOR9(7, 7, 7) }, 100, 160, 72, SCREEN_ARRAY(levelE), R_heightmapE_hm_zx0 }, // 8
    { { COLOR9(7, 4, 1) }, { COLOR9(6, 3, 0) }, { COLOR9(7, 7, 7) }, 110, 160, 70, SCREEN_ARRAY(levelN), R_heightmapN_hm_zx0 }, // 9
    { { COLOR9(7, 7, 7) }, { COLOR9(6, 6, 0) }, { COLOR9(0, 0, 5) }, 115, 160, 69, SCREEN_ARRAY(levelP), R_heightmapP_hm_zx0 }, // 10
    { { COLOR9(7, 7, 7) }, { COLOR9(1, 2, 3) }, { COLOR9(7, 7, 7) }, 120, 160, 68, SCREEN_ARRAY(levelJ), R_heightmapJ_hm_zx0 }, // 11
    { { COLOR9(7, 7, 7) }, { COLOR9(3, 3, 5) }, { COLOR9(7, 7, 7) }, 125, 160, 67, SCREEN_ARRAY(levelQ), R_heightmapQ_hm_zx0 }, // 12
    { { COLOR9(5, 7, 2) }, { COLOR9(1, 5, 1) }, { COLOR9(7, 7, 7) }, 130, 160, 66, SCREEN_ARRAY(levelC), R_heightmapC_hm_zx0 }, // 13
    { { COLOR9(7, 6, 6) }, { COLOR9(3, 2, 2) }, { COLOR9(7, 7, 7) }, 130, 160, 64, SCREEN_ARRAY(levelK), R_heightmapK_hm_zx0 }, // 14
    { { COLOR9(7, 2, 0) }, { COLOR9(2, 0, 1) }, { COLOR9(7, 7, 7) }, 130, 160, 62, SCREEN_ARRAY(levelM), R_heightmapM_hm_zx0 }, // 15
    { { COLOR9(7, 2, 4) }, { COLOR9(0, 0, 2) }, { COLOR9(7, 7, 7) }, 130, 160, 60, SCREEN_ARRAY(levelF), R_heightmapF_hm_zx0 }, // 16
    { { COLOR9(1, 1, 1) }, { COLOR9(0, 0, 0) }, { COLOR9(7, 7, 7) }, 130, 160, 50, SCREEN_ARRAY(levelH), R_heightmapH_hm_zx0 }  // 17
};
