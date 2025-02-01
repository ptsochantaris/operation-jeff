#include "resources.h"

static byte targetType, presentedType;
static word currentX;
static word currentY;
static word bonusLoop;
static word bonusTime;
static byte transition;

void resetBonuses(void) __z88dk_fastcall {
    targetType = BONUS_NONE;
    presentedType = BONUS_NONE;
    currentX = 0;
    currentY = 0;
    bonusLoop = 450;
    bonusTime = 500;

    clearTilemap();
}

void setBase(byte *base, byte value) {
    ZXN_WRITE_MMU3(11);
    *base = value;
    ZXN_WRITE_MMU3(10);
}

void updateBonuses(void) __z88dk_fastcall {
    if(++bonusLoop == bonusTime) {
        if(targetType==BONUS_NONE) {
            targetType = 1 + rand() % BONUS_MAX;
            currentX = 3 + rand() % 36;
            currentY = 3 + rand() % 28;
            transition = 0;
        }
        bonusLoop = 0;
    }

    if(targetType == presentedType) {
        if(targetType != BONUS_NONE) {
            bomb *b = bombs;
            word roundedX = currentX - 1;
            word roundedY = currentY - 1;
            for(byte f=0; f!=bombCount; ++f, ++b) {
                if(b->state == BOMB_STATE_EXPLODING) {
                    if((b->sprite.pos.x >> 3 == roundedX) && (b->sprite.pos.y >> 3 == roundedY)) {
                        processBonusHit(targetType);
                        targetType = BONUS_NONE;
                        break;
                    }
                }
            }
        }
    } else {
        byte *base = (byte *)tilemapAddress + currentX + currentY * 40;
        if(transition==12) {
            presentedType = targetType;
            setBase(base, targetType);
        } else {
            byte transitionOffset = 2 * (transition >> 2);
            ++transition;
            switch(presentedType) {
                case BONUS_NONE:
                    switch(targetType) {
                        case BONUS_HEALTH:
                        case BONUS_SCORE:
                        case BONUS_CHARGE:
                            setBase(base, 5 + transitionOffset);

                            break;
                        case BONUS_SMARTBOMB:
                            setBase(base, 6 + transitionOffset);
                            break;
                    }
                    break;
                case BONUS_HEALTH:
                case BONUS_SCORE:
                case BONUS_CHARGE:
                    setBase(base, 9 - transitionOffset);
                    break;
                case BONUS_SMARTBOMB:
                    setBase(base, 10 - transitionOffset);
                    break;
            }
        }
    }
}
