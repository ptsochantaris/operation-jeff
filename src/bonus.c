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
        ++currentStats.bonusesLanded;
        return;
    }

    byte transitionOffset = 3 * (transition >> 2);
    ++transition;
    switch(presentedType) {
        case BONUS_NONE:
            scrollTilemap(0, 24 - (transition << 1));
            switch(targetType) {
                case BONUS_HEALTH:
                case BONUS_SCORE:
                case BONUS_CHARGE:
                    setBase(6 + transitionOffset);
                    return;
                case BONUS_SMARTBOMB:
                    setBase(7 + transitionOffset);
                    return;
                case BONUS_FREEZE:
                    setBase(8 + transitionOffset);
                    return;
            }
            return;
        case BONUS_HEALTH:
        case BONUS_SCORE:
        case BONUS_CHARGE:
            scrollTilemap(0, transition << 1);
            setBase(12 - transitionOffset);
            return;
        case BONUS_SMARTBOMB:
            scrollTilemap(0, transition << 1);
            setBase(13 - transitionOffset);
            return;
        case BONUS_FREEZE:
            scrollTilemap(0, transition << 1);
            setBase(14 - transitionOffset);
            return;
    }
}
