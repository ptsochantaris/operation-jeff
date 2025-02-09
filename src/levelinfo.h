#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"
#include "assets.h"

#define LEVEL_COUNT 15

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

extern LevelInfo titleInfo, infoInfo, gameOverInfo;
extern LevelInfo levelInfo[];

#endif
