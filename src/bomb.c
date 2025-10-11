#include "base.h"

#define BOMB_FIRST 25
#define BOMB_LAST 29
#define BOMB_LAUNCHED 41

struct bomb bombs[bombCount];

struct bomb* explodingBombs[bombCount];
byte explodingBombCount = 0;

static byte bombLoop = 0;
static byte cooldown = 0;

void initBombs(void) __z88dk_fastcall {
    cooldown = 0;
    explodingBombCount = 0;
    struct bomb *b = bombs;
    for(byte f=0; f!=bombCount; ++f, ++b) {
        b->sprite.index = f;
        b->sprite.scaleUp = 0;
        b->state = BOMB_STATE_NONE;
        b->outcome = BOMB_OUTCOME_NONE;
    }
}

static const word bombColorIndex[] = { 240, 245, 249, 254 };
static const word whiteColor = 0x01ff;
static word bombStash[] = { 0, 0, 0, 0 };

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

    struct bomb *b = bombs;
    for(const struct bomb *end = b+bombCount; b != end; ++b) {
        if(b->state != BOMB_STATE_NONE) {
            continue;
        }

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
        b->outcome = BOMB_OUTCOME_NONE;
        b->sprite.pattern = BOMB_FIRST;

        if(currentStats.extraRangeBombs > 0) {
            --currentStats.extraRangeBombs;
        }
        return;
    }
}

void resetAllBombs(void) __z88dk_fastcall {
    explodingBombCount = 0;
    struct bomb *b = bombs;
    for(const struct bomb *end = b+bombCount; b != end; ++b) {
        if(b->state == BOMB_STATE_NONE) {
            continue;
        }
        b->state = BOMB_STATE_NONE;
        b->outcome = BOMB_OUTCOME_NONE;
        b->sprite.scaleUp = 0;
        hideSprite(b->sprite.index);
    }
}

static void startBombExplosion(struct bomb *restrict b) {
    b->state = BOMB_STATE_EXPLODING;
    b->sprite.pattern = BOMB_EXPLOSION_FIRST;
    b->sprite.scaleUp = currentStats.extraRangeBombs;
    explodingBombs[explodingBombCount++] = b;
}

static void endBombExplosion(struct bomb *restrict b) {
    b->state = BOMB_STATE_NONE;
    b->sprite.scaleUp = 0;
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
    hideSprite(b->sprite.index);

    if(explodingBombCount > 1) {
        for(byte count=0; count<explodingBombCount; ++count) {
            if(explodingBombs[count]==b) {
                explodingBombs[count] = explodingBombs[explodingBombCount - 1];
                --explodingBombCount;
                return;
            }
        }
    } else {
        explodingBombCount = 0;
    }
}

void updateBombs(void) __z88dk_fastcall {
    if(bombLoop) {
        struct bomb *b = bombs;
        for(const struct bomb *end = b+bombCount; b != end; ++b) {
            switch(b->state) {
                case BOMB_STATE_NONE:
                    break;

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

    if(mouseState.handled == 0) {
        mouseState.handled = 1;
        fireIfPossible();

    } else if(mouseState.ongoing) {
        fireIfPossible();

    } else if(cooldown) {
        --cooldown;
    }
}
