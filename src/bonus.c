#include "resources.h"

static byte targetType, presentedType, lastTargetType;
static word currentX;
static word currentY;
static word bonusLoop;
static byte transition;

#define bonusTime 600

static void setBase(byte value) __z88dk_fastcall {
    byte *base = (byte *)tilemapAddress + currentX + currentY * 40;
    ZXN_WRITE_MMU3(11);
    *base = value;
    ZXN_WRITE_MMU3(10);
}

void resetBonuses(void) __z88dk_fastcall {
    setBase(BONUS_NONE);

    scrollTilemap(0, 0);

    targetType = BONUS_NONE;
    presentedType = BONUS_NONE;
    lastTargetType = BONUS_FREEZE;
    currentX = 0;
    currentY = 0;
    bonusLoop = 450;
    transition = 0;
}

static const byte bonusIndexes[] = {
    BONUS_HEALTH,
    BONUS_CHARGE,
    BONUS_SMARTBOMB,
    BONUS_SMARTBOMB,
    BONUS_RATE,
    BONUS_SCORE,
    BONUS_SCORE,
    BONUS_FREEZE,
    BONUS_FREEZE,
    BONUS_SLOW,
    BONUS_SLOW,
    BONUS_INVUNERABLE,
    BONUS_RANGE,
    BONUS_UMBRELLA
};
#define BONUS_INDEX_COUNT 14

static void newRandomTargetType(void) {
    do {
        byte i = random16() % BONUS_INDEX_COUNT;
        targetType = bonusIndexes[i];
    } while(lastTargetType == targetType);

    lastTargetType = targetType;
}

void updateBonuses(void) __z88dk_fastcall {
    if(++bonusLoop == bonusTime) {
        bonusLoop = 0;

        // time to add new bonus, if none exists
        if(targetType==BONUS_NONE) {
            setBase(0); // in case a previous bonus is in the process of transitioning out
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

    if(targetType == presentedType) {
        if(targetType == BONUS_NONE || explodingBombCount == 0) {
            return;
        }

        int centerX = (currentX << 3) - 4;
        int centerY = (currentY << 3) - 4;
        int radius = currentStats.extraRangeBombs ? 18 : 8;
        int C;
        for(byte count=0; count<explodingBombCount; ++count) {
            struct bomb *b = explodingBombs[count];
            C = b->sprite.pos.x - radius;
            if(centerX < C) continue;
            C += (radius << 1);
            if(centerX >= C) continue;
            C = b->sprite.pos.y - radius;
            if(centerY < C) continue;
            C += (radius << 1);
            if(centerY >= C) continue;

            processBonusHit(targetType);
            targetType = BONUS_NONE;
            transition = 0;
            b->outcome |= BOMB_OUTCOME_BONUS_HIT;
            return;
        }
        return;
    }

    if(transition==12) {
        scrollTilemap(0, 0);
        presentedType = targetType;
        setBase(targetType);
        return;
    }

    byte transitionOffset = 3 * (transition >> 2);
    ++transition;
    switch(presentedType) {
        case BONUS_NONE:
            scrollTilemap(0, 24 - (transition << 1));
            switch(targetType) {
                case BONUS_SCORE:
                case BONUS_HEALTH:
                case BONUS_CHARGE:
                    setBase(BONUS_MAX + 1 + transitionOffset);
                    return;
                case BONUS_SMARTBOMB:
                    setBase(BONUS_MAX + 2 + transitionOffset);
                    return;
                case BONUS_FREEZE:
                case BONUS_UMBRELLA:
                case BONUS_SLOW:
                case BONUS_INVUNERABLE:
                case BONUS_RANGE:
                case BONUS_RATE:
                    setBase(BONUS_MAX + 3 + transitionOffset);
                    return;
            }
            return;

        case BONUS_SCORE:
        case BONUS_HEALTH:
        case BONUS_CHARGE:
            scrollTilemap(0, transition << 1);
            setBase(BONUS_MAX + 7 - transitionOffset);
            return;

        case BONUS_SMARTBOMB:
            scrollTilemap(0, transition << 1);
            setBase(BONUS_MAX + 8 - transitionOffset);
            return;

        case BONUS_FREEZE:
        case BONUS_UMBRELLA:
        case BONUS_SLOW:
        case BONUS_INVUNERABLE:
        case BONUS_RANGE:
        case BONUS_RATE:
            scrollTilemap(0, transition << 1);
            setBase(BONUS_MAX + 9 - transitionOffset);
            return;
    }
}
