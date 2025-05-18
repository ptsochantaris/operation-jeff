#include "resources.h"

#define BOMB_FIRST 25
#define BOMB_LAST 29
#define BOMB_LAUNCHED 41

#define EXPLOSION_FIRST 10
#define EXPLOSION_LAST 15

struct bomb bombs[bombCount];

static byte bombLoop = 0;
static byte cooldown = 0;

void initBombs(void) __z88dk_fastcall {
    cooldown = 0;
    struct bomb *b = bombs;
    for(byte f=0; f!=bombCount; ++f, ++b) {
        b->sprite.index = f;
        b->state = BOMB_STATE_NONE;
        b->outcome = BOMB_OUTCOME_NONE;
    }
}

#define FIRE_ENERGY 4

void fireIfPossible(void) __z88dk_fastcall {
    if(cooldown) {
        --cooldown;
        return;
    }

    if(currentStats.energy < FIRE_ENERGY) {
        return;
    }

    struct bomb *b = bombs;
    for(struct bomb *end = b+bombCount; b != end; ++b) {
        if(b->state == BOMB_STATE_NONE) {
            if(currentStats.supergun == 0) {
                currentStats.energy -= FIRE_ENERGY;
                cooldown = currentStats.fireRate >> 1;
            } else {
                --currentStats.supergun;
                cooldown = 1;
            }
            b->countdown = 22;
            b->target = mouseState.pos;
            b->sprite.pos.x = mouseState.pos.x;
            b->sprite.pos.y = 255;
            b->state = BOMB_STATE_TICKING;
            b->outcome = BOMB_OUTCOME_NONE;
            b->sprite.pattern = BOMB_FIRST;
            effectFire();
            return;
        }
    }
}

void resetAllBombs(void) __z88dk_fastcall {
    struct bomb *b = bombs;
    for(struct bomb *end = b+bombCount; b != end; ++b) {
        if(b->state != BOMB_STATE_NONE) {
            b->state = BOMB_STATE_NONE;
            b->outcome = BOMB_OUTCOME_NONE;
            hideSprite(b->sprite.index);
        }
    }
}

void updateBombs(void) __z88dk_fastcall {
    if(bombLoop) {
        struct bomb *b = bombs;
        for(struct bomb *end = b+bombCount; b != end; ++b) {
            switch(b->state) {
                case BOMB_STATE_NONE:
                    break;

                case BOMB_STATE_TICKING:
                    struct coord pos = b->sprite.pos;
                    pos.y += (b->target.y - pos.y) >> 2;
                    b->sprite.pos = pos;

                    byte countdown = --(b->countdown);
                    if(countdown < 17) {
                        if(countdown == 0) {
                            b->sprite.pattern = EXPLOSION_FIRST;
                            b->state = BOMB_STATE_EXPLODING;
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
                    if(++(b->sprite.pattern) > EXPLOSION_LAST) {
                        b->state = BOMB_STATE_NONE;
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
