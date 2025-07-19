#ifndef __STATS_H__
#define __STATS_H__

#define FIRE_RATE_MAX 14
#define FIRE_RATE_MIN 2

#define HIGHSCORE_SLOTS 10
#define HIGHSCORE_SLOT_NAME_LEN 10

#include "types.h"

typedef struct ScoreRecord {
    byte name[HIGHSCORE_SLOT_NAME_LEN+1];
    long score;
};

typedef struct stats {
    byte energy;
    byte health;
    byte fireRate;
    
    unsigned long score;
    unsigned long shotsHit;
    unsigned long shotsMiss;
    unsigned long bonusesLanded;
    unsigned long bonusesHit;
    unsigned long frames;

    byte level;
    byte generationPeriod;
    byte generationCountdown;

    byte supergun;
    byte extraRangeBombs;

    word holdCount;
    word invunerableCount;
    word difficultyCountdown;

    byte slowMo;
    byte sloMoHold;

    word killsInLevel;
    word maxKillsInLevel;
    word difficultyStepInLevel;
};

extern struct stats currentStats;
extern struct ScoreRecord highScores[];

void initStats(void) __z88dk_fastcall;
void setupGameStats(void) __z88dk_fastcall;
void statsProgressLevel(void) __z88dk_fastcall;
void statsInitLevel(void) __z88dk_fastcall;
byte processGameStats(void) __z88dk_fastcall;
void processFireStats(void) __z88dk_fastcall;
void processJeffKill(byte speed) __z88dk_fastcall;
void processBonusHit(byte type) __z88dk_fastcall;
void processJeffHit(void) __z88dk_fastcall;
void newHighScore(byte *name, byte pos);
word displayHighScoreTable(word x, word top, byte newPos);

#endif
