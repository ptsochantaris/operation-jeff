#include "resources.h"

#define DAMAGE 50

struct stats currentStats;

struct ScoreRecord highScores[] = {
    { "MINILAMB  ", 1000 },
    { "MACROLAMB ", 900 },
    { "MAXILAMB  ", 800 },
    { "MICROLAMB ", 700 },
    { "MINTYLAMB ", 600 },
    { "MILLILAMB ", 500 },
    { "MINILAMP  ", 400 },
    { "REGULAMB  ", 300 },
    { "PICOLAMB  ", 200 },
    { "JEFFFFFFFF", 100 }
};

void initStats(void) __z88dk_fastcall {
    int len = sizeof(highScores);
    fetchData(&highScores, len);
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

void newHighScore(byte *name, byte pos) {
    byte i = HIGHSCORE_SLOTS - 1;
    while(i > pos) {
        highScores[i] = highScores[--i];
    }
    highScores[pos].score = currentStats.score;
    memcpy(highScores[pos].name, name, HIGHSCORE_SLOT_NAME_LEN);
    
    word len = sizeof(highScores);
    persistData(highScores, len);
}

word displayHighScoreTable(word x, word top, byte newPos) {
    word entryTop = 0;
    word row = 0;
    for(byte i = 0; i < HIGHSCORE_SLOTS; ++i) {
        byte color;
        long score;
        top += 10;
        if(i == newPos) {
            layer2fill(x - 1, top - 1, 4*10 + 1, 7, HUD_BLACK);
            layer2roundedBox(x - 2, top - 2, 4*10 + 2, 8, HUD_WHITE);    
            entryTop = top;
            color = HUD_WHITE;
            score = currentStats.score;
            newPos = 255;
        } else {
            struct ScoreRecord record = highScores[row];
            printNoBackground(record.name, x, top, HUD_ORANGE);    
            color = HUD_ORANGE;      
            score = record.score;
            ++row;
        }
        sprintf(textBuf, "%07lu", score);
        printNoBackground(textBuf, x + 48, top, color);    
    }
    return entryTop;
}

void statsProgressLevel(void) __z88dk_fastcall {
    ++currentStats.level;
    
    if(currentStats.level == LEVEL_COUNT) {
        currentStats.level = 0;
    }
}

void statsInitLevel(void) __z88dk_fastcall {
    const struct LevelInfo info = levelInfo[currentStats.level];

    currentStats.killsInLevel = 0;
    currentStats.difficultyCountdown = 0;
    currentStats.generationPeriod = info.initialGenerationPeriod;
    currentStats.generationCountdown = currentStats.generationPeriod;
    currentStats.difficultyStepInLevel = info.difficultyStep;
    currentStats.maxKillsInLevel = info.killsRequired;
    currentStats.supergun = 0;

    currentStats.shotsHit = 0;
    currentStats.shotsMiss = 0;
    currentStats.bonusesHit = 0;
    currentStats.bonusesLanded = 0;
    currentStats.frames = 0;
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
            return;

        case BONUS_SMARTBOMB: 
            effectBomb();
            flashPaletteUp();
            jeffKillAll(0);
            flashPaletteDown();
            return;

        case BONUS_CHARGE: 
            currentStats.energy = 255;
            status("+CHARGE");
            break;

        case BONUS_HEALTH: 
            currentStats.health = 255;
            status("+HEALTH");
            break;

        case BONUS_RATE: 
            currentStats.supergun = 80;
            status("SUPERGUN");
            break;

        case BONUS_SCORE: 
            currentStats.score += 100;
            status("+100 PTS");
            break;

        case BONUS_FREEZE:
            currentStats.holdCount = 200;
            break;
    }

    effectBonus();
    effectZap();
}

void processJeffHit(void) __z88dk_fastcall {
    byte canSurvive = currentStats.health >= DAMAGE;
    if(canSurvive) currentStats.health -= DAMAGE;
    else currentStats.health = 0;
}

void processJeffKill(byte score) __z88dk_fastcall {
    currentStats.score += score;
    ++currentStats.killsInLevel;
}
