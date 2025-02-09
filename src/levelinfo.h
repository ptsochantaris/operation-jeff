#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"

#define LEVEL_COUNT 15

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

typedef struct {
    word resource;
    word length;
    byte page;        
} ResourceInfo;

typedef struct {
    byte jeffBright[2];
    byte jeffDark[2];
    word killsRequired;
    word difficultyStep;
    byte initialGenerationPeriod;
    ResourceInfo screens[10], paletteAsset;
} LevelInfo;

extern LevelInfo levelInfo[];

#endif
