#ifndef __LEVEL_INFO__
#define __LEVEL_INFO__

#include "types.h"
#include "assets.h"

#define LEVEL_COUNT 14

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
    ResourceInfo screen0, screen1, screen2, screen3, screen4, screen5, screen6, screen7, screen8, screen9, paletteAsset;
} LevelInfo;

extern LevelInfo titleInfo, infoInfo, gameOverInfo;
extern LevelInfo levelInfo[];

#endif
