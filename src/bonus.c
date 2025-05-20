#include "resources.h"

static byte targetType, presentedType, lastTargetType;
static word currentX;
static word currentY;
static word bonusLoop;
static byte transition;

#define bonusTime 500

void resetBonuses(void) __z88dk_fastcall {
    targetType = BONUS_NONE;
    presentedType = BONUS_NONE;
    lastTargetType = BONUS_FREEZE;
    currentX = 0;
    currentY = 0;
    bonusLoop = 450;

    clearTilemap();
}

void setBase(byte value) __z88dk_fastcall {
    byte *base = (byte *)tilemapAddress + currentX + currentY * 40;
    ZXN_WRITE_MMU3(11);
    *base = value;
    ZXN_WRITE_MMU3(10);
}

void updateBonuses(void) __z88dk_fastcall {
    if(++bonusLoop == bonusTime) {
        bonusLoop = 0;

        // time to add new bonus, if none exists
        if(targetType==BONUS_NONE) {
            setBase(0); // in case a previous bonus is in the process of transitioning out
            byte newTarget;
            do {
                newTarget = 1 + rand() % BONUS_MAX;
            } while(newTarget == lastTargetType);
            targetType = newTarget;
            lastTargetType = newTarget;
            currentX = 3 + rand() % 36;
            currentY = 3 + rand() % 28;
            transition = 0;
            ++currentStats.bonusesLanded;
        } else {
            // expire previous bonus
            targetType = BONUS_NONE;
            transition = 0;
        }
    }

    if(targetType == presentedType) {
        if(targetType == BONUS_NONE) {
            return;
        }

        word roundedX = currentX - 1;
        word roundedY = currentY - 1;
        struct bomb *b = bombs;
        for(struct bomb *end = b+bombCount; b != end; ++b) {
            if((b->state == BOMB_STATE_EXPLODING) && (b->sprite.pos.x >> 3 == roundedX) && (b->sprite.pos.y >> 3 == roundedY)) {
                processBonusHit(targetType);
                targetType = BONUS_NONE;
                transition = 0;
                b->outcome |= BOMB_OUTCOME_BONUS_HIT;
                return;
            }
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
                case BONUS_PAUSE:
                case BONUS_SLOW:
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
        case BONUS_PAUSE:
        case BONUS_SLOW:
        case BONUS_RATE:
            scrollTilemap(0, transition << 1);
            setBase(BONUS_MAX + 9 - transitionOffset);
            return;
    }
}
