#include "resources.h"

#define FIRE_ENERGY 4
#define DAMAGE 50

stats currentStats;

void initStats(void) __z88dk_fastcall {
    setupGameStats();
    currentStats.hiScore = 0;
}

void setupGameStats(void) __z88dk_fastcall {
    currentStats.energy = 0x80;
    currentStats.health = 0x80;
    currentStats.score = 0;
    currentStats.fireRate = FIRE_RATE_MIN + (FIRE_RATE_MAX - FIRE_RATE_MIN) / 2;
    currentStats.level = 255; // so it loops to zero at game start
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
            ++(currentStats.energy);
            hudEnergyUpdated();
        }
    }

    byte healthPoint = 80 + chargePoint * 20;
    if(++healthLoop > healthPoint) {
        healthLoop = 0;
        if(currentStats.health < 255) {
            ++(currentStats.health);
            hudHealthUpdated();
        }
    }

    if(currentStats.health == 0) {
        return 1;
    }

    if(mouseState.wheel != 0) {
        if(mouseState.wheel > 0 && currentStats.fireRate < FIRE_RATE_MAX) {
            ++currentStats.fireRate;
            hudRateUpdated();
        } else if(mouseState.wheel < 0 && currentStats.fireRate > FIRE_RATE_MIN) {
            --currentStats.fireRate;
            hudRateUpdated();
        }
        mouseState.wheel = 0;
    }

    if(currentStats.killsInLevel > currentStats.maxKillsInLevel) {
        return 2;
    }

    return 0;
}

byte canFire(void) __z88dk_fastcall {
    byte canFire = currentStats.energy >= FIRE_ENERGY;
    if(canFire) {
        currentStats.energy -= FIRE_ENERGY;
        hudEnergyUpdated();
    }
    return canFire;
}

void processBonusHit(byte type) __z88dk_fastcall {
    switch(type) {
        case BONUS_NONE: 
            break;

        case BONUS_CHARGE: 
            currentStats.energy = 255;
            hudEnergyUpdated();
            status("+CHARGE");
            effectBonus();
            effectZap();
            break;

        case BONUS_HEALTH: 
            currentStats.health = 255;
            hudHealthUpdated();
            status("+HEALTH");
            effectBonus();
            effectZap();
            break;

        case BONUS_SCORE: 
            currentStats.score += 100;
            hudScoreUpdated();
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
    }
}

void processJeffHit(void) __z88dk_fastcall {
    byte canSurvive = currentStats.health >= DAMAGE;
    if(canSurvive) currentStats.health -= DAMAGE;
    else currentStats.health = 0;
    hudHealthUpdated();
}

void processJeffKill(byte score) __z88dk_fastcall {
    currentStats.score += score;
    if(currentStats.hiScore < currentStats.score) {
        currentStats.hiScore = currentStats.score;
    }
    hudScoreUpdated();
    ++currentStats.killsInLevel;
    hudKillsUpdated();
}
