#include "resources.h"

#define jeffCount 80

#define LANDING_AIR 30
#define LANDING_HIT 31

#define JEFF_FRONT_STAND 0
#define JEFF_FRONT_FIRST 1
#define JEFF_FRONT_LAST 8

#define JEFF_BACK_STAND 16
#define JEFF_BACK_FIRST 17
#define JEFF_BACK_LAST 24

#define JEFF_SIDE_STAND 32
#define JEFF_SIDE_FIRST 33
#define JEFF_SIDE_LAST 40
#define JEFF_APPEAR_FIRST 52
#define JEFF_APPEAR_LAST 63
#define JEFF_DISAPPEAR_FIRST 42
#define JEFF_DISAPPEAR_LAST 51

#define JEFF_STATE_NONE 0
#define JEFF_STATE_STAND 1
#define JEFF_STATE_WALK 2
#define JEFF_STATE_APPEAR 3
#define JEFF_STATE_DISAPPEAR 4
#define JEFF_STATE_LANDING 5

#define JEFF_LEFT 0
#define JEFF_RIGHT 1
#define JEFF_UP 2
#define JEFF_DOWN 3

#define BOMB_RANGE 24
#define BOMB_CLOSE 6

typedef struct {
  sprite_info sprite;
  byte state;
  byte direction;
  word moveMask;
  byte progress;
} jeff;

typedef struct {
    sprite_info sprite;
    byte active;
    jeff *passenger;
} lander;

static lander landing;
static jeff jeffs[jeffCount];
static word logicLoop = 1;

#define DAMAGE_FLASH_DURATION 12
static byte damageFlash;

// 0000 0100 0000 0100
#define JEFF_SPEED_MASK_0 0x0404
// 0000 0100 0000 0100
#define JEFF_SPEED_MASK_1 0x0404
// 0010 0001 0000 1000
#define JEFF_SPEED_MASK_2 0x2108
// 0010 0001 0001 0001
#define JEFF_SPEED_MASK_3 0x2108
// 0010 0001 0001 0001
#define JEFF_SPEED_MASK_4 0x2111
// 0100 1010 0010 0010
#define JEFF_SPEED_MASK_5 0x2111
// 0100 1010 0010 0010
#define JEFF_SPEED_MASK_6 0x4A22
// 0101 0100 0101 0101
#define JEFF_SPEED_MASK_7 0x5455
// 0101 0101 0101 0101
#define JEFF_SPEED_MASK_8 0x5555

#define JEFF_SPEED_MASK_COUNT 9
static const word jeffMoveMasks[] = { 
    JEFF_SPEED_MASK_0,
    JEFF_SPEED_MASK_1,
    JEFF_SPEED_MASK_2,
    JEFF_SPEED_MASK_3,
    JEFF_SPEED_MASK_4,
    JEFF_SPEED_MASK_5,
    JEFF_SPEED_MASK_6,
    JEFF_SPEED_MASK_7,
    JEFF_SPEED_MASK_8
};

void growJeff(jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_LANDING;
    j->direction = rand() % 4;
    if(j->direction == JEFF_LEFT) {
        j->sprite.attrs = 8;
    } else {
        j->sprite.attrs = 0;
    }
    j->moveMask = JEFF_SPEED_MASK_4;
    j->progress = 0;
    j->sprite.pattern = JEFF_APPEAR_FIRST;
    switch(j->direction) {
        case JEFF_LEFT:
            j->sprite.pos.x = 160 + rand() % 64 * 2;
            j->sprite.pos.y = 16 + rand() % 224;
            break;

        case JEFF_RIGHT:
            j->sprite.pos.x = 16 + rand() % 64 * 2;
            j->sprite.pos.y = 16 + rand() % 224;
            break;

        case JEFF_UP:
            j->sprite.pos.x = 16 + rand() % 288;
            j->sprite.pos.y = 128 + rand() % 112;
            break;

        case JEFF_DOWN:
            j->sprite.pos.x = 16 + rand() % 288;
            j->sprite.pos.y = 16 + rand() % 112;
            break;
    }

    landing.sprite.pos.x = j->sprite.pos.x;
    landing.sprite.pos.y = 0;
    landing.sprite.pattern = LANDING_AIR;
    landing.passenger = j;
    landing.active = 1;

    effectLand();
}

void initJeffs(void) __z88dk_fastcall {
    damageFlash = 0;
    landing.active = 0;
    landing.sprite.index = 126;
    jeff *j = jeffs;
    for(byte f=0;f!=jeffCount;++f, ++j) {
        j->state = JEFF_STATE_NONE;
        j->sprite.index = f + bombCount;
    }
}

void launchRandomJeff(void) __z88dk_fastcall {
    // reverse so the new jeff will grow behind existing ones
    byte c = jeffCount - 1;
    jeff *j = jeffs + c;
    for(byte f=0 ; f!=c; ++f, --j) {
        if(j->state == JEFF_STATE_NONE) {
            growJeff(j);
            return;
        }
    }
}

void killJeff(jeff *restrict j) __z88dk_fastcall {
    processJeffKill(j->moveMask);
    j->sprite.pattern = JEFF_DISAPPEAR_FIRST;
    j->state = JEFF_STATE_DISAPPEAR;
    j->moveMask = JEFF_SPEED_MASK_4;

    effectExplosion();
}

void jeffHit(jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_NONE;
    processJeffHit();

    damageFlash = DAMAGE_FLASH_DURATION;
    setHudBackground(0x40); // redish
    effectDamage();
}

void jeffCheckBombs(jeff *restrict j) __z88dk_fastcall {
    bomb *b = bombs;
    word C;
    word jx = j->sprite.pos.x;
    word jy = j->sprite.pos.y;
    for(byte f=0; f!=bombCount; ++f, ++b) {
        if(b->state == BOMB_STATE_EXPLODING) {
            word bx = b->sprite.pos.x;
            word by = b->sprite.pos.y;
            C = bx - (BOMB_RANGE>>1);
            if(jx < C) {
                break;
            }
            C += BOMB_RANGE;
            if(jx >= C) {
                break;
            }
            C = by - (BOMB_RANGE>>1) - 4;
            if(jy < C) {
                break;
            }
            C += BOMB_RANGE;
            if(jy >= C) {
                break;
            }

            killJeff(j);

            C = bx - (BOMB_CLOSE>>1);
            if(jx < C) {
                return;
            }
            C += BOMB_CLOSE;
            if(jx >= C) {
                return;
            }
            C = by - (BOMB_CLOSE>>1) - 4;
            if(jy < C) {
                return;
            }
            C += BOMB_CLOSE;
            if(jy >= C) {
                return;
            }
            status("+10 PTS", 1);
            currentStats.score += 10;
            return;
        }
    }
    return;
}

void jeffWalkStep(jeff *restrict j) __z88dk_fastcall {
    ++(j->sprite.pattern);
    switch(j->direction) {
        case JEFF_UP:                        
            --(j->sprite.pos.y);
            if(j->sprite.pos.y == 0) {
                jeffHit(j);
            } else if(j->sprite.pattern > JEFF_BACK_LAST) {
                j->sprite.pattern = JEFF_BACK_FIRST;
            }
            break;

        case JEFF_DOWN:
            ++(j->sprite.pos.y);
            if(j->sprite.pos.y == 256) {
                jeffHit(j);
            } else if(j->sprite.pattern > JEFF_FRONT_LAST) {
                j->sprite.pattern = JEFF_FRONT_FIRST;
            }
            break;

        case JEFF_LEFT:
            j->sprite.pos.x -= 2;
            if(j->sprite.pos.x == 0) {
                jeffHit(j);
            } else if(j->sprite.pattern > JEFF_SIDE_LAST) {
                j->sprite.pattern = JEFF_SIDE_FIRST;
            }
            break;

        case JEFF_RIGHT:
            j->sprite.pos.x += 2;
            if(j->sprite.pos.x == 320) {
                jeffHit(j);
            } else if(j->sprite.pattern > JEFF_SIDE_LAST) {
                j->sprite.pattern = JEFF_SIDE_FIRST;
            }
            break;
    }
}

void jeffStandStep(jeff *j) __z88dk_fastcall {
    switch(j->direction) {
        case JEFF_LEFT:
            j->sprite.pattern = JEFF_SIDE_STAND;
            break;
        case JEFF_RIGHT:
            j->sprite.pattern = JEFF_SIDE_STAND;
            break;
        case JEFF_UP:
            j->sprite.pattern = JEFF_BACK_STAND;
            break;
        case JEFF_DOWN:
            j->sprite.pattern = JEFF_FRONT_STAND;
            break;
    }

    if(++(j->progress) > 10) {
        j->progress = 0;
        j->state = JEFF_STATE_WALK;
        switch(j->direction) {
            case JEFF_LEFT:
            case JEFF_RIGHT:
                j->sprite.pattern = JEFF_SIDE_FIRST;
                break;
            case JEFF_UP:
                j->sprite.pattern = JEFF_BACK_FIRST;
                break;
            case JEFF_DOWN:
                j->sprite.pattern = JEFF_FRONT_FIRST;
                break;
        }
    }
}

void jeffAppearStep(jeff *j) __z88dk_fastcall {
    if(++(j->sprite.pattern) > JEFF_APPEAR_LAST) {
        j->state = JEFF_STATE_STAND;
        j->progress = 0;
        byte maskIndex = rand() % JEFF_SPEED_MASK_COUNT;
        j->moveMask = *(jeffMoveMasks+maskIndex);
        jeffStandStep(j);
    }
}

void jeffKillAll(void) __z88dk_fastcall {
    jeff *j = jeffs;
    for(byte f=0; f!=jeffCount; ++f, ++j) {
        switch(j->state) {
            case JEFF_STATE_STAND:
            case JEFF_STATE_WALK:
            killJeff(j);
        }
    }
}

void updateJeffs(void) __z88dk_fastcall {
    if(damageFlash) {
        if(--damageFlash == 0) {
            setHudBackground(0);
        }

    } else if(++currentStats.difficultyCountdown == currentStats.difficultyStepInLevel) {
        currentStats.difficultyCountdown = 0;
        if(currentStats.generationPeriod > 10) {
            --currentStats.generationPeriod;
        }
    }

    if(landing.active) {
        jeff *j = landing.passenger;
        if(landing.sprite.pattern == LANDING_HIT) {
            j->state = JEFF_STATE_APPEAR;
            landing.active = 0;
            updateSprite(&j->sprite);
            hideSprite(126);
        } else {
            landing.sprite.pos.y+=16;
            if(landing.sprite.pos.y >= j->sprite.pos.y) {
                landing.sprite.pos.y = j->sprite.pos.y;
                landing.sprite.pattern = LANDING_HIT;
            }
            updateSprite(&landing.sprite);
        }
    }

    if(currentStats.generationCountdown==0) {
        if(!landing.active) {
            currentStats.generationCountdown = currentStats.generationPeriod;
            launchRandomJeff();
        }
    } else {
        --currentStats.generationCountdown;
    }

    logicLoop = (logicLoop << 1) | (logicLoop >> 15);

    jeff *j = jeffs;
    for(byte f=0; f!=jeffCount; ++f, ++j) {
        if(!(j->moveMask & logicLoop)) {
            continue;
        }

        switch(j->state) {
            case JEFF_STATE_LANDING:
            case JEFF_STATE_NONE:
                continue; // do not update sprite

            case JEFF_STATE_STAND:
                jeffStandStep(j);
                jeffCheckBombs(j);
                break;

            case JEFF_STATE_APPEAR:
                jeffAppearStep(j);
                break;

            case JEFF_STATE_DISAPPEAR:
                if(++(j->sprite.pattern) > JEFF_DISAPPEAR_LAST) {
                    j->state = JEFF_STATE_NONE;
                    j->moveMask = 0;
                    hideSprite(j->sprite.index);
                    continue;
                }
                break;

            case JEFF_STATE_WALK:
                jeffWalkStep(j);
                jeffCheckBombs(j);
                break;
        }

        updateSprite(&j->sprite);
    }
}
