#include "resources.h"

#define BOMB_FIRST 25
#define BOMB_LAST 29
#define BOMB_LAUNCHED 41

#define EXPLOSION_FIRST 10
#define EXPLOSION_LAST 15

bomb bombs[bombCount];

static byte bombLoop = 0;
static byte cooldown = 0;

void initBombs(void) __z88dk_fastcall {
    cooldown = 0;
    bomb *b = bombs;
    for(byte f=0; f!=bombCount; ++f, ++b) {
        b->sprite.index = f;
        b->state = BOMB_STATE_NONE;
    }
}

void fireIfPossible(void) __z88dk_fastcall {
    if(cooldown) {
        --cooldown;
        return;
    }
    if(canFire()) {
        bomb *b = bombs;
        for(byte f=0; f!=bombCount; ++f, ++b) {
            if(b->state == BOMB_STATE_NONE) {
                b->countdown = 22;
                b->target = mouseClicked.pos;
                b->sprite.pos.x = mouseClicked.pos.x;
                b->sprite.pos.y = 255;
                b->state = BOMB_STATE_TICKING;
                b->sprite.pattern = BOMB_FIRST;
                cooldown = currentStats.fireRate;
                return;
            }
        }
    }
}

void updateBombs(void) __z88dk_fastcall {
    if(bombLoop) {
        bomb *b = bombs;
        for(byte f=0; f!=bombCount; ++f, ++b) {
            switch(b->state) {
                case BOMB_STATE_NONE:
                    break;

                case BOMB_STATE_TICKING:
                    b->sprite.pos.x += (b->target.x - b->sprite.pos.x) >> 2;
                    b->sprite.pos.y += (b->target.y - b->sprite.pos.y) >> 2;
                    updateSprite(&b->sprite);
                    if(--(b->countdown) == 0) {
                        b->sprite.pattern = EXPLOSION_FIRST;
                        b->state = BOMB_STATE_EXPLODING;
                    } else if(b->countdown < 17) {
                        if(++(b->sprite.pattern) > BOMB_LAST) {
                            b->sprite.pattern = BOMB_FIRST;
                        }
                    } else {
                        b->sprite.pattern = BOMB_LAUNCHED;
                    }
                    break;

                case BOMB_STATE_EXPLODING:
                    if(++(b->sprite.pattern) > EXPLOSION_LAST) {
                        b->state = BOMB_STATE_NONE;
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

    if(mouseClicked.handled == 0) {
        mouseClicked.handled = 1;
        fireIfPossible();

    } else if(mouseClicked.ongoing) {
        fireIfPossible();

    } else if(cooldown) {
        --cooldown;
    }
}
