#include "base.h"

#define BOMB_FIRST 25
#define BOMB_LAST 29
#define BOMB_LAUNCHED 41

struct bomb* explodingBombs[bombCount];
byte explodingBombCount = 0;

static struct bomb* idleBombs[bombCount];
static byte idleBombCount = 0;

static struct bomb* activeBombs[bombCount];
static byte activeBombCount = 0;

static byte bombLoop = 0;
static byte cooldown = 0;

static struct bomb *nextIdleBomb(void) {
    if(idleBombCount==0) return NULL;
    struct bomb *b = idleBombs[--idleBombCount];
    activeBombs[activeBombCount++] = b;
    return b;
}

static void retireBomb(struct bomb *b) {
    hideSprite(b->sprite.index);
    b->sprite.scaleUp = 0;
    b->state = BOMB_STATE_NONE;
    b->outcome = BOMB_OUTCOME_NONE;
    idleBombs[idleBombCount++] = b;

    if(activeBombCount < 2) {
        activeBombCount = 0;
        return;
    }

    const byte lastIndex = activeBombCount - 1;
    activeBombCount = lastIndex;
    for(byte count=0; count<lastIndex; ++count) {
        if(activeBombs[count]==b) {
            activeBombs[count] = activeBombs[lastIndex];
            return;
        }
    }
}

static struct bomb bombStore[bombCount];
static const word bombColorIndex[] = { 240, 245, 249, 254 };
static const word whiteColor = 0x01ff;
static word bombStash[] = { 0, 0, 0, 0 };

void initBombs(void) __z88dk_fastcall {
    cooldown = 0;
    explodingBombCount = 0;
    idleBombCount = 0;
    activeBombCount = 0;
    struct bomb *b = bombStore;
    for(byte f = 0; f != bombCount; ++f, ++b) {
        b->sprite.index = f;
        retireBomb(b);
    }
}

void bombsRestoreFromFlash(void) __z88dk_fastcall {
    selectPalette(2);
    for(byte i=0; i != 4; ++i) {
        word index = *(bombColorIndex+i);
        writeColourToIndex(bombStash+i, index);
    }
}

void bombsFlashAll(void) __z88dk_fastcall {
    selectPalette(2);
    for(byte i=0; i != 4; ++i) {
        word index = *(bombColorIndex+i);
        readColourFromIndex(bombStash+i, index);
        writeColourToIndex(&whiteColor, index);
    }
}

#define FIRE_ENERGY 4

static void fireIfPossible(void) __z88dk_fastcall {
    if(cooldown) {
        --cooldown;
        return;
    }

    if(currentStats.energy < FIRE_ENERGY) {
        return;
    }

    struct bomb *b = nextIdleBomb();
    if(!b) return;

    effectFire();

    if(currentStats.supergun == 0) {
        currentStats.energy -= FIRE_ENERGY;
        cooldown = currentStats.fireRate >> 1;
    } else {
        --currentStats.supergun;
        cooldown = 1;
    }
    b->countdown = 22;
    b->target.x = mouseX;
    b->target.y = mouseY;
    b->sprite.pos.x = mouseX;
    b->sprite.pos.y = 255;
    b->state = BOMB_STATE_TICKING;
    b->sprite.pattern = BOMB_FIRST;

    if(currentStats.extraRangeBombs > 0) {
        --currentStats.extraRangeBombs;
    }
}

void resetAllBombs(void) __z88dk_fastcall {
    explodingBombCount = 0;
    while(activeBombCount > 0) {
        retireBomb(activeBombs[0]);
    }
}

static void startBombExplosion(struct bomb *restrict b) {
    b->state = BOMB_STATE_EXPLODING;
    b->sprite.pattern = BOMB_EXPLOSION_FIRST;
    b->sprite.scaleUp = currentStats.extraRangeBombs;
    explodingBombs[explodingBombCount++] = b;
}

static void endBombExplosion(struct bomb *restrict b) {
    byte outcome = b->outcome;
    if(outcome) {
        if(outcome & BOMB_OUTCOME_JEFF_KILL) {
            ++currentStats.shotsHit;
        }
        if(outcome & BOMB_OUTCOME_BONUS_HIT) {
            ++currentStats.bonusesHit;
        }
    } else {
        ++currentStats.shotsMiss;
    }
    retireBomb(b);

    if(explodingBombCount > 1) {
        const byte lastIndex = explodingBombCount - 1;
        explodingBombCount = lastIndex;
        for(byte count=0; count<lastIndex; ++count) {
            if(explodingBombs[count]==b) {
                explodingBombs[count] = explodingBombs[lastIndex];
                return;
            }
        }
    } else {
        explodingBombCount = 0;
    }
}

void updateBombs(void) __z88dk_fastcall {
    if(bombLoop) {

        struct bomb **B = activeBombs;
        for(const struct bomb **E = activeBombs+activeBombCount; B != E; ++B) {
            struct bomb *b = *B;
            switch(b->state) {
                case BOMB_STATE_TICKING:
                    b->sprite.pos.y += (b->target.y - b->sprite.pos.y) >> 2;

                    byte countdown = --(b->countdown);
                    if(countdown < 17) {
                        if(countdown == 0) {
                            startBombExplosion(b);
                        } else {    
                            if(++(b->sprite.pattern) > BOMB_LAST) {
                                b->sprite.pattern = BOMB_FIRST;
                            }
                        }
                    } else {
                        b->sprite.pattern = BOMB_LAUNCHED;
                    }
                    updateSprite(&b->sprite);
                    break;

                case BOMB_STATE_EXPLODING:
                    if(++(b->sprite.pattern) > BOMB_EXPLOSION_LAST) {
                        endBombExplosion(b);
                    } else {
                        updateSprite(&b->sprite);
                    }
                    break;
            }
        }
        bombLoop = 0;
        return;
    }

    bombLoop++;

    if(!mouseState.handled) {
        mouseState.handled = 1;
        fireIfPossible();

    } else if(mouseState.ongoing) {
        fireIfPossible();

    } else if(cooldown) {
        --cooldown;
    }
}

void bombIfPossible(int x, int y) __z88dk_callee {
    struct bomb *b = nextIdleBomb();
    if(!b) return;

    b->countdown = 0;
    b->target.x = x;
    b->target.y = y;
    b->sprite.pos.x = x;
    b->sprite.pos.y = y;
    startBombExplosion(b);
}
