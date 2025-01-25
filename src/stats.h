#ifndef __STATS_H__
#define __STATS_H__

#define FIRE_RATE_MAX 7
#define FIRE_RATE_MIN 1
#define LEVEL_COUNT 8

#include "types.h"

typedef struct {
    byte energy;
    byte health;
    byte fireRate;
    
    long score;
    long hiScore;

    byte level;
    byte generationPeriod;
    byte generationCountdown;
    word difficultyCountdown;

    word killsInLevel;
    word maxKillsInLevel;
    word difficultyStepInLevel;
} stats;

extern stats currentStats;

void initStats(void) __z88dk_fastcall;
void setupGameStats(void) __z88dk_fastcall;
void statsProgressLevel(void) __z88dk_fastcall;
byte processGameStats(void) __z88dk_fastcall;
byte canFire(void) __z88dk_fastcall;
void processFireStats(void) __z88dk_fastcall;
void processJeffKill(byte speed) __z88dk_fastcall;
void processBonusHit(byte type) __z88dk_fastcall;
void processJeffHit(void) __z88dk_fastcall;

#endif
