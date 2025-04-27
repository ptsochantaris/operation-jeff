#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"

#define LEVEL_COUNT 16

#define SCREEN_ARRAY(X) { \
    R_##X##_0_nxi_zx0, \
    R_##X##_1_nxi_zx0, \
    R_##X##_2_nxi_zx0, \
    R_##X##_3_nxi_zx0, \
    R_##X##_4_nxi_zx0, \
    R_##X##_5_nxi_zx0, \
    R_##X##_6_nxi_zx0, \
    R_##X##_7_nxi_zx0, \
    R_##X##_8_nxi_zx0, \
    R_##X##_9_nxi_zx0 \
}, R_##X##_nxp_zx0

typedef struct ResourceInfo {
    word resource;
    word length;
    byte page;        
};

#define FAKE_LEVEL(L) { { 0,0 }, { 0,0 }, { 0,0 }, 0, 0, 0, SCREEN_ARRAY(L), {0, 0, 0} }

typedef struct LevelInfo {
    byte jeffBright[2];
    byte jeffDark[2];
    byte fontDark[2];
    word killsRequired;
    word difficultyStep;
    byte initialGenerationPeriod;
    struct ResourceInfo screens[10], paletteAsset, heightmapAsset;
};

extern struct LevelInfo levelInfo[];

#endif
