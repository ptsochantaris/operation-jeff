#include "resources.h"

#define DAMAGE 50

stats currentStats;

typedef struct {
    long hiScore;
} SavedStats;

static SavedStats savedStats;

void initStats(void) __z88dk_fastcall {
    savedStats.hiScore = 0;
    int len = sizeof(savedStats);
    fetchData(&savedStats, len);
    currentStats.hiScore = savedStats.hiScore;
    setupGameStats();
}

void setupGameStats(void) __z88dk_fastcall {
    currentStats.energy = 0x80;
    currentStats.health = 0x80;
    currentStats.holdCount = 0;
    currentStats.score = 0;
    currentStats.fireRate = FIRE_RATE_MIN + (FIRE_RATE_MAX - FIRE_RATE_MIN) / 2;
    currentStats.level = 255; // so it loops to zero at game start
}

void newHighScore(void) __z88dk_fastcall {
    savedStats.hiScore = currentStats.score;
    int len = sizeof(savedStats);
    persistData(&savedStats, len);
}

void statsProgressLevel(void) __z88dk_fastcall {
    ++currentStats.level;
    
    if(currentStats.level == LEVEL_COUNT) {
        currentStats.level = 0;
    }

    const LevelInfo info = levelInfo[currentStats.level];

    currentStats.killsInLevel = 0;
    currentStats.difficultyCountdown = 0;
    currentStats.generationPeriod = info.initialGenerationPeriod;
    currentStats.generationCountdown = currentStats.generationPeriod;
    currentStats.difficultyStepInLevel = info.difficultyStep;
    currentStats.maxKillsInLevel = info.killsRequired;
}

static byte energyLoop = 0;
static byte healthLoop = 0;

byte processGameStats(void) __z88dk_fastcall {
    byte chargePoint = FIRE_RATE_MAX - currentStats.fireRate;
    
    if(++energyLoop > chargePoint) {
        energyLoop = 0;
        if(currentStats.energy < 255) {
            ++currentStats.energy;
        }
    }

    byte healthPoint = 80 + chargePoint * 20;
    if(++healthLoop > healthPoint) {
        healthLoop = 0;
        if(currentStats.health < 255) {
            ++(currentStats.health);
        }
    }

    if(currentStats.health == 0) {
        return 1;
    }

    if(mouseState.wheel != 0) {
        if(mouseState.wheel > 0 && currentStats.fireRate < FIRE_RATE_MAX) {
            ++currentStats.fireRate;
        } else if(mouseState.wheel < 0 && currentStats.fireRate > FIRE_RATE_MIN) {
            --currentStats.fireRate;
        }
        mouseState.wheel = 0;
    }

    if(currentStats.killsInLevel > currentStats.maxKillsInLevel) {
        return 2;
    }

    return 0;
}

void processBonusHit(byte type) __z88dk_fastcall {
    switch(type) {
        case BONUS_NONE: 
            break;

        case BONUS_CHARGE: 
            currentStats.energy = 255;
            status("+CHARGE");
            effectBonus();
            effectZap();
            break;

        case BONUS_HEALTH: 
            currentStats.health = 255;
            status("+HEALTH");
            effectBonus();
            effectZap();
            break;

        case BONUS_SCORE: 
            currentStats.score += 100;
            status("+100 PTS");
            effectBonus();
            effectZap();
            break;

        case BONUS_SMARTBOMB: 
            jeffKillAll();
            status("BOOM!");
            effectBonus();
            effectZap();
            break;

        case BONUS_FREEZE:
            effectBonus();
            effectZap();
            currentStats.holdCount = 200;
            break;
    }
}

void processJeffHit(void) __z88dk_fastcall {
    byte canSurvive = currentStats.health >= DAMAGE;
    if(canSurvive) currentStats.health -= DAMAGE;
    else currentStats.health = 0;
}

void processJeffKill(byte score) __z88dk_fastcall {
    currentStats.score += score;
    if(currentStats.hiScore < currentStats.score) {
        currentStats.hiScore = currentStats.score;
    }
    ++currentStats.killsInLevel;
}
