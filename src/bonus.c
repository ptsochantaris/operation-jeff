#include "resources.h"

static byte targetType, presentedType, lastTargetType;
static word currentX;
static word currentY;
static word bonusLoop;
static word bonusTime;
static byte transition;

void resetBonuses(void) __z88dk_fastcall {
    targetType = BONUS_NONE;
    presentedType = BONUS_NONE;
    lastTargetType = BONUS_FREEZE;
    currentX = 0;
    currentY = 0;
    bonusLoop = 450;
    bonusTime = 500;

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
        if(targetType==BONUS_NONE) {
            setBase(0); // this in case a previous bonus is in the process of transitioning out
            byte newTarget;
            do {
                newTarget = 1 + rand() % BONUS_MAX;
            } while(newTarget == lastTargetType);
            targetType = newTarget;
            lastTargetType = newTarget;
            currentX = 3 + rand() % 36;
            currentY = 3 + rand() % 28;
            transition = 0;
        }
        bonusLoop = 0;
    }

    if(targetType == presentedType) {
        if(targetType != BONUS_NONE) {
            word roundedX = currentX - 1;
            word roundedY = currentY - 1;
            bomb *b = bombs;
            for(bomb *end = b+bombCount; b != end; ++b) {
                if(b->state == BOMB_STATE_EXPLODING) {
                    if((b->sprite.pos.x >> 3 == roundedX) && (b->sprite.pos.y >> 3 == roundedY)) {
                        processBonusHit(targetType);
                        targetType = BONUS_NONE;
                        transition = 0;
                        break;
                    }
                }
            }
        }
    } else {
        if(transition==12) {
            scrollTilemap(0, 0);
            presentedType = targetType;
            setBase(targetType);
        } else {
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
                            break;
                        case BONUS_SMARTBOMB:
                            setBase(7 + transitionOffset);
                            break;
                        case BONUS_FREEZE:
                            setBase(8 + transitionOffset);
                            break;
                    }
                    break;
                case BONUS_HEALTH:
                case BONUS_SCORE:
                case BONUS_CHARGE:
                    scrollTilemap(0, transition << 1);
                    setBase(12 - transitionOffset);
                    break;
                case BONUS_SMARTBOMB:
                    scrollTilemap(0, transition << 1);
                    setBase(13 - transitionOffset);
                    break;
                case BONUS_FREEZE:
                    scrollTilemap(0, transition << 1);
                    setBase(14 - transitionOffset);
                    break;
            }
        }
    }
}
