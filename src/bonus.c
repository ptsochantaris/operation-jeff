#include "base.h"

static byte targetType, presentedType, lastTargetType;
static word currentX;
static word currentY;
static word bonusLoop;
static byte transition;
static byte magnetActive;

#define bonusTime 600

// Addresses into tilemap
extern word hollowPlusTiles;
extern word hollowDiamondTiles;
extern word hollowSquareTiles;
extern word hollowMagnetTiles;
extern word activeMagnetTiles;
extern word tilesBase;

// Assembled by tiles.asm as the tile count times four frames each, so adding a
// frame to the category extends the cycle on its own. The length is the symbol's
// value, not its contents, so taking the address is what reads it.
extern byte activeMagnetCycle;
#define ACTIVE_MAGNET_CYCLE ((byte)(word)&activeMagnetCycle)

static void placeTile(word *categoryBase, int offset) __z88dk_callee {
    byte *base = (byte *)tilemapAddress + currentX + currentY * 40;
    ZXN_WRITE_MMU3(11);
    *base = ((categoryBase - &tilesBase) >> 4) + offset;
    ZXN_WRITE_MMU3(10);
}

void resetBonuses(void) __z88dk_fastcall {
    placeTile(&tilesBase, BONUS_NONE);

    targetType = BONUS_NONE;
    presentedType = BONUS_NONE;
    lastTargetType = BONUS_FREEZE;
    currentX = 0;
    currentY = 0;
    bonusLoop = 450;
    transition = 0;
    magnetActive = 0;
}

static const byte bonusIndexes[] = {
    BONUS_HEALTH,
    BONUS_CHARGE,
    BONUS_SMARTBOMB,
    BONUS_SMARTBOMB,
    BONUS_MINIBOMB,
    BONUS_MINIBOMB,
    BONUS_MINIBOMB,
    BONUS_RATE,
    BONUS_SCORE,
    BONUS_ZAP,
    BONUS_FREEZE,
    BONUS_FREEZE,
    BONUS_MAGNET,
    BONUS_SLOW,
    BONUS_INVUNERABLE,
    BONUS_RANGE,
    BONUS_UMBRELLA
};
#define BONUS_INDEX_COUNT 17

static void newRandomTargetType(void) __z88dk_fastcall {
    do {
        byte i = random16() % BONUS_INDEX_COUNT;
        targetType = bonusIndexes[i];
    } while(lastTargetType == targetType);
    // targetType = BONUS_MINIBOMB;
    lastTargetType = targetType;
}

static void processBonusState(void) __z88dk_fastcall {
    bonusLoop = 0;

    // time to add new bonus, if none exists
    if(targetType==BONUS_NONE) {
        placeTile(&tilesBase, 0); // in case a previous bonus is in the process of transitioning out
        newRandomTargetType();
        currentX = 3 + random16() % 36;
        currentY = 3 + random16() % 28;
        transition = 0;
        ++currentStats.bonusesLanded;
    } else {
        // expire previous bonus
        targetType = BONUS_NONE;
        transition = 0;
    }
}

static void processTargetType(const byte transitionOffset) __z88dk_fastcall {
    switch(targetType) {
        case BONUS_SCORE:
        case BONUS_HEALTH:
        case BONUS_CHARGE:
            placeTile(&hollowPlusTiles, transitionOffset);
            return;

        case BONUS_SMARTBOMB:
        case BONUS_ZAP:
            placeTile(&hollowDiamondTiles, transitionOffset);
            return;

        case BONUS_FREEZE:
        case BONUS_UMBRELLA:
        case BONUS_SLOW:
        case BONUS_INVUNERABLE:
        case BONUS_MINIBOMB:
        case BONUS_RANGE:
        case BONUS_RATE:
            placeTile(&hollowSquareTiles, transitionOffset);
            return;

        case BONUS_MAGNET:
            placeTile(&hollowMagnetTiles, transitionOffset);
            return;
    }
}

static void proceessBonusTransition(void) __z88dk_fastcall {
    if(transition==24) {
        presentedType = targetType;
        placeTile(&tilesBase, targetType);
        return;
    }

    const byte transitionOffset = transition++ >> 3;

    switch(presentedType) {
        case BONUS_NONE:
            processTargetType(transitionOffset);
            return;

        case BONUS_SCORE:
        case BONUS_HEALTH:
        case BONUS_CHARGE:
            placeTile(&hollowDiamondTiles, -transitionOffset);
            return;

        case BONUS_SMARTBOMB:
        case BONUS_ZAP:
            placeTile(&hollowSquareTiles, -transitionOffset);
            return;

        case BONUS_FREEZE:
        case BONUS_UMBRELLA:
        case BONUS_SLOW:
        case BONUS_INVUNERABLE:
        case BONUS_RANGE:
        case BONUS_MINIBOMB:
        case BONUS_RATE:
            placeTile(&hollowMagnetTiles, -transitionOffset);
            return;

        case BONUS_MAGNET:
            placeTile(&activeMagnetTiles, -transitionOffset);
            return;
    }
}

static void processPresentedBonus(void) __z88dk_fastcall {
    if(currentStats.magnetLocation.z) {
        // magnetActive doubles as the "is active" flag, so it cycles 1..count<<2
        // rather than from zero, and the tile offset takes the bias back off.
        magnetActive += 1;
        if(magnetActive > ACTIVE_MAGNET_CYCLE) magnetActive = 1;
        placeTile(&activeMagnetTiles, (magnetActive - 1) >> 2);
        return;
    }
    
    if (magnetActive) {
        placeTile(&tilesBase, 0);
        magnetActive = 0;
    }

    if(targetType == BONUS_NONE || explodingBombCount == 0) {
        return;
    }

    const int centerX = (currentX << 3) - 4;
    const int centerY = (currentY << 3) - 4;
    const int *lookup = currentStats.extraRangeBombs ? &bombRadii2 : &bombRadii1;

    struct bomb **B = explodingBombs;
    for(const struct bomb **E = explodingBombs+explodingBombCount; B != E; ++B) {
        struct bomb *b = *B;
        const byte radiusIndex = b->sprite.pattern - BOMB_EXPLOSION_FIRST;
        const int radius = *(lookup+radiusIndex);

        int C = b->sprite.pos.x - radius;
        if(centerX < C) continue;
        C += (radius << 1);
        if(centerX >= C) continue;
        C = b->sprite.pos.y - radius;
        if(centerY < C) continue;
        C += (radius << 1);
        if(centerY >= C) continue;

        processBonusHit(targetType, centerX, centerY);
        targetType = BONUS_NONE;
        transition = 0;
        b->outcome |= BOMB_OUTCOME_BONUS_HIT;
        return;
    }
}

void updateBonuses(void) __z88dk_fastcall {
    if(!magnetActive && ++bonusLoop == bonusTime) {
        processBonusState();
    }

    if(targetType == presentedType) {
        processPresentedBonus();
    } else {
        proceessBonusTransition();
    }
}
