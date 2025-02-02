#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"

#define LEVEL_COUNT 12

typedef struct {
    byte jeffBright[2];
    byte jeffDark[2];
    word killsRequired;
    word difficultyStep;
    byte initialGenerationPeriod;
    byte memoryPage;
    byte paletteOffset;
} LevelInfo;

extern LevelInfo *levelInfo[];

#endif
