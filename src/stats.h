#ifndef __STATS_H__
#define __STATS_H__

#define FIRE_RATE_MAX 14
#define FIRE_RATE_MIN 2

#include "types.h"

typedef struct stats {
    byte energy;
    byte health;
    byte fireRate;
    
    long score;
    long hiScore;

    byte level;
    byte generationPeriod;
    byte generationCountdown;
    word holdCount;
    word difficultyCountdown;

    word killsInLevel;
    word maxKillsInLevel;
    word difficultyStepInLevel;
};

extern struct stats currentStats;

void initStats(void) __z88dk_fastcall;
void setupGameStats(void) __z88dk_fastcall;
void statsProgressLevel(void) __z88dk_fastcall;
byte processGameStats(void) __z88dk_fastcall;
void processFireStats(void) __z88dk_fastcall;
void processJeffKill(byte speed) __z88dk_fastcall;
void processBonusHit(byte type) __z88dk_fastcall;
void processJeffHit(void) __z88dk_fastcall;
void newHighScore(void) __z88dk_fastcall;

#endif
