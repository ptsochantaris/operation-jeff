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

static byte heightMap[HEIGHTMAP_WIDTH * HEIGHTMAP_HEIGHT];

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

void loadHeightmap(const LevelInfo *restrict info) __z88dk_callee {
    ZXN_WRITE_MMU1(info->heightmapAsset.page);
    decompressZX0(heightMap, (byte *)(info->heightmapAsset.resource));
  }

coord setJeffPos(coord pos, byte direction) __z88dk_callee {
    byte interpolate = 1;
    int vertical = 14;
    int horizontal = 8;

    switch(direction) {
        case JEFF_UP:
        --pos.y;
        vertical = 10;
        break;

        case JEFF_DOWN:
        ++pos.y;
        vertical = 18;
        break;

        case JEFF_LEFT:
        pos.x -= 2;
        horizontal = 4;
        break;

        case JEFF_RIGHT:
        pos.x += 2;
        horizontal = 12;
        break;

        default:
        interpolate = 0;
        break;
    }

    int lookupX = (pos.x + horizontal) >> 2;
    int lookupY = (pos.y + vertical) >> 2;
    int targetZ = *(heightMap + lookupX + lookupY * HEIGHTMAP_WIDTH);
    if(interpolate) {
        if(targetZ > pos.z) {
            ++pos.z;
        } else if(targetZ < pos.z) {
            --pos.z;
        }
        return pos;
    } else {
        pos.z = targetZ;
        return pos;
    }
}

void growJeff(jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_LANDING;
    j->progress = 0;
    byte maskIndex = rand() % JEFF_SPEED_MASK_COUNT;
    j->moveMask = *(jeffMoveMasks+maskIndex);

    byte direction = rand() % 4;
    j->direction = direction;
    j->sprite.attrs = (direction == JEFF_LEFT) ? 8 : 0;
    j->sprite.pattern = JEFF_APPEAR_FIRST;

    coord pos;

    switch(direction) {
        case JEFF_LEFT:
            pos.x = 160 + (rand() & 0x3F) * 2;
            pos.y = 40 + rand() % 192;
            break;

        case JEFF_RIGHT:
            pos.x = 16 + (rand() & 0x3F) * 2;
            pos.y = 40 + rand() % 192;
            break;

        case JEFF_UP:
            pos.x = 16 + rand() % 288;
            pos.y = 128 + rand() % 112;
            break;

        case JEFF_DOWN:
            pos.x = 16 + rand() % 288;
            pos.y = 16 + rand() % 112;
            break;
    }

    pos = setJeffPos(pos, 255);
    j->sprite.pos = pos;

    landing.sprite.pos = pos;
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
    for(jeff *j = jeffs + jeffCount - 1; j >= jeffs; --j) {
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

    effectExplosion();
}

void jeffEscape(jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_NONE;
    processJeffHit();

    damageFlash = DAMAGE_FLASH_DURATION;
    setHudBackground(0x40); // redish
    effectDamage();
}

void jeffCheckBombs(jeff *restrict j) __z88dk_fastcall {
    int C;
    coord spos = j->sprite.pos;
    int jx = spos.x;
    int jy = spos.y - spos.z;
    if(jy<0) jy = 0;

    bomb *b = bombs;
    for(bomb *end = b+bombCount; b != end; ++b) {
        if(b->state == BOMB_STATE_EXPLODING) {
            coord pos = b->sprite.pos;
            C = pos.x - (BOMB_RANGE>>1);
            if(jx < C) continue;
            C += BOMB_RANGE;
            if(jx >= C) continue;
            C = pos.y - (BOMB_RANGE>>1) - 4;
            if(jy < C) continue;
            C += BOMB_RANGE;
            if(jy >= C) continue;

            killJeff(j);

            C = pos.x - (BOMB_CLOSE>>1);
            if(jx < C) return;
            C += BOMB_CLOSE;
            if(jx >= C) return;
            C = pos.y - (BOMB_CLOSE>>1) - 4;
            if(jy < C) return;
            C += BOMB_CLOSE;
            if(jy >= C) return;

            status("+10 PTS");
            effectZap();
            currentStats.score += 10;
            return;
        }
    }
}

void jeffWalkStep(jeff *restrict j) __z88dk_fastcall {
    byte newPattern = ++(j->sprite.pattern);
    byte direction = j->direction;
    coord pos = setJeffPos(j->sprite.pos, direction);
    j->sprite.pos = pos;
    switch(direction) {
        case JEFF_UP:
            if(pos.y == 0) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_BACK_LAST) {
                    j->sprite.pattern = JEFF_BACK_FIRST;
                }
            }
            break;

        case JEFF_DOWN:
            if(pos.y == 255) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_FRONT_LAST) {
                    j->sprite.pattern = JEFF_FRONT_FIRST;
                }
            }
            break;

        case JEFF_LEFT:
            if(pos.x == 0) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_SIDE_LAST) {
                    j->sprite.pattern = JEFF_SIDE_FIRST;
                }
            }
            break;

        case JEFF_RIGHT:
            if(pos.x == 320) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_SIDE_LAST) {
                    j->sprite.pattern = JEFF_SIDE_FIRST;
                }
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
        jeffStandStep(j);
    }
}

void jeffKillAll(void) __z88dk_fastcall {
    jeff *j = jeffs;
    for(jeff *end = j+jeffCount; j != end; ++j) {
        switch(j->state) {
            case JEFF_STATE_STAND:
            case JEFF_STATE_WALK:
            killJeff(j);
        }
    }
}

void holdStep(void) __z88dk_fastcall {
    word v = currentStats.holdCount--;
    if(v == 1) {
        status(NULL);
    } else if(v % 40 == 0) {
        sprintf(textBuf, "%d", v / 40);
        status(textBuf);
    }
}

void updateJeffs(void) __z88dk_fastcall {
    if(damageFlash) {
        if(--damageFlash == 0) {
            setHudBackground(0);
        }
        scrollLayer2((damageFlash % 2), 0);

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
            int Y = j->sprite.pos.y;
            if(landing.sprite.pos.y >= Y) {
                landing.sprite.pos.y = Y;
                landing.sprite.pattern = LANDING_HIT;
            }
            updateSprite(&landing.sprite);
        }
    }

    if(currentStats.holdCount == 0) {
        if(currentStats.generationCountdown==0) {
            if(!landing.active) {
                currentStats.generationCountdown = currentStats.generationPeriod;
                launchRandomJeff();
            }
        } else {
            --currentStats.generationCountdown;
        }
    } else {
        holdStep();
    }

    logicLoop = (logicLoop << 1) | (logicLoop >> 15);

    jeff *j = jeffs;
    for(jeff *end = jeffs+jeffCount; j != end; ++j) {
        switch(j->state) {
            case JEFF_STATE_LANDING:
            case JEFF_STATE_NONE:
                break;

            case JEFF_STATE_STAND:
                if(j->moveMask & logicLoop) {
                    jeffStandStep(j);
                    jeffCheckBombs(j);
                    updateSprite(&j->sprite);
                }
                break;

            case JEFF_STATE_APPEAR:
                if(JEFF_SPEED_MASK_4 & logicLoop) {
                    jeffAppearStep(j);
                    updateSprite(&j->sprite);
                }
                break;

            case JEFF_STATE_DISAPPEAR:
                if(JEFF_SPEED_MASK_4 & logicLoop) {
                    if(++(j->sprite.pattern) > JEFF_DISAPPEAR_LAST) {
                        j->state = JEFF_STATE_NONE;
                        hideSprite(j->sprite.index);
                    } else {
                        updateSprite(&j->sprite);
                    }
                }
                break;

            case JEFF_STATE_WALK:
                if(j->moveMask & logicLoop) {
                    if(currentStats.holdCount == 0) {
                        jeffWalkStep(j);
                    }
                    jeffCheckBombs(j);
                    updateSprite(&j->sprite);
                }
                break;
        }
    }
}
