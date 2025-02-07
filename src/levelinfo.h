#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"
#include "assets.h"

#define LEVEL_COUNT 12

typedef struct {
    byte jeffBright[2];
    byte jeffDark[2];
    word killsRequired;
    word difficultyStep;
    byte initialGenerationPeriod;
    ResourceInfo *screenArray[10];
    ResourceInfo *paletteAsset;
} LevelInfo;

extern LevelInfo *levelInfo[];

#endif
