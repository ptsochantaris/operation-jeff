#include "base.h"

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

#define BOMB_CLOSE 6

typedef struct jeff {
  struct sprite_info sprite;
  byte state;
  byte direction;
  word moveMask;
  byte progress;
};

typedef struct lander {
    struct sprite_info sprite;
    byte active;
    struct jeff *passenger;
};

static struct lander landing;
static struct jeff jeffStore[jeffCount];

static struct jeff *idleJeff[jeffCount];
static byte idleJeffCount = 0;

static struct jeff *activeJeff[jeffCount];
static byte activeJeffCount = 0;

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

void loadHeightmap(const struct ResourceInfo *restrict heightmapAsset) __z88dk_fastcall {
    ZXN_WRITE_MMU1(heightmapAsset->page);
    decompressZX0((byte *)(heightmapAsset->resource), heightMap);
}

static void setJeffPos(struct jeff *restrict j, byte direction) __z88dk_callee __smallc {
    struct sprite_info *s = &(j->sprite);
    int vertical, horizontal;

    switch(direction) {
        case JEFF_UP:
        --(s->pos.y);
        vertical = 10;
        horizontal = 8;
        break;

        case JEFF_DOWN:
        ++(s->pos.y);
        vertical = 18;
        horizontal = 8;
        break;

        case JEFF_LEFT:
        s->pos.x -= 2;
        vertical = 14;
        horizontal = 6;
        break;

        case JEFF_RIGHT:
        s->pos.x += 2;
        vertical = 14;
        horizontal = 6;
        break;
    }

    int lookupX = (s->pos.x + horizontal) >> 2;
    int lookupY = (s->pos.y + vertical) >> 2;
    int targetZ = *(heightMap + lookupX + lookupY * HEIGHTMAP_WIDTH);
    int currentZ = s->pos.z;

    if(currentZ == targetZ) {
        return;
    }

    if(direction == 255) {
        s->pos.z = targetZ;
        return;
    }

    int diff = (targetZ - currentZ);
    if(diff > 2) {
        s->pos.z += 2;
    } else if(diff < -2) {
        s->pos.z -= 2;
    } else {
        s->pos.z = targetZ;
    }
}

static void growJeff(struct jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_LANDING;
    j->progress = 0;
    byte maskIndex = random16() % JEFF_SPEED_MASK_COUNT;
    j->moveMask = *(jeffMoveMasks+maskIndex);

    byte direction = random16() % 4;
    j->direction = direction;
    j->sprite.horizontalMirror = (direction == JEFF_LEFT) ? 1 : 0;
    j->sprite.pattern = JEFF_APPEAR_FIRST;

    switch(direction) {
        case JEFF_LEFT:
            j->sprite.pos.x = 160 + (random16() & 0x3F) * 2;
            j->sprite.pos.y = 40 + random16() % 192;
            break;

        case JEFF_RIGHT:
            j->sprite.pos.x = 16 + (random16() & 0x3F) * 2;
            j->sprite.pos.y = 40 + random16() % 192;
            break;

        case JEFF_UP:
            j->sprite.pos.x = 16 + random16() % 288;
            j->sprite.pos.y = 128 + random16() % 112;
            break;

        case JEFF_DOWN:
            j->sprite.pos.x = 16 + random16() % 288;
            j->sprite.pos.y = 16 + random16() % 112;
            break;
    }

    setJeffPos(j, 255);

    landing.sprite.pos = j->sprite.pos;
    landing.sprite.pos.y = 0;
    landing.sprite.pattern = LANDING_AIR;
    landing.passenger = j;
    landing.active = 1;

    effectLand();
}

static struct jeff *nextAvailableJeff(void) {
    if(idleJeffCount==0) {
        return NULL;
    }
    // reverse so the new jeff will grow behind existing ones
    struct jeff *j = idleJeff[--idleJeffCount];
    activeJeff[activeJeffCount++] = j;
    return j;
}

static void retireJeff(struct jeff *restrict j) __z88dk_fastcall {
    j->state = JEFF_STATE_NONE;
    hideSprite(j->sprite.index);
    idleJeff[idleJeffCount++] = j;

    if(activeJeffCount < 2) {
        activeJeffCount = 0;
        return;
    }

    const byte lastIndex = activeJeffCount - 1;
    activeJeffCount = lastIndex;
    for(byte count=0; count<lastIndex; ++count) {
        if(activeJeff[count]==j) {
            activeJeff[count] = activeJeff[lastIndex];
            return;
        }
    }
}

void initJeffs(void) __z88dk_fastcall {
    damageFlash = 0;
    landing.active = 0;
    landing.sprite.index = 126;
    idleJeffCount = 0;
    activeJeffCount = 0;
    struct jeff *j = jeffStore;
    for(byte f=0;f!=jeffCount;++f, ++j) {
        j->sprite.index = f + bombCount;
        retireJeff(j);
    }
}

static void launchRandomJeff(void) __z88dk_fastcall {
    struct jeff *j;
    if(j = nextAvailableJeff()) {
        growJeff(j);
    }
}

static void killJeff(struct jeff *restrict j) __z88dk_fastcall {
    processJeffKill(j->moveMask);
    j->sprite.pattern = JEFF_DISAPPEAR_FIRST;
    j->state = JEFF_STATE_DISAPPEAR;
}

static void jeffEscape(struct jeff *restrict j) __z88dk_fastcall {
    retireJeff(j);

    if(currentStats.invunerableCount > 0) {
        return;
    }

    effectDamage();
    processJeffHit();

    damageFlash = DAMAGE_FLASH_DURATION;
    setFallbackColour(0x40); // redish
}

void jeffFlashAll(void) __z88dk_fastcall {
    // flash jeffs white
    selectPalette(2);
    const word white = 0x01FF;
    writeColourToIndex(&white, 128);
    writeColourToIndex(&white, 224);
}

static byte jeffCheckBombs(struct jeff *restrict j) __z88dk_fastcall {
    if(explodingBombCount==0) {
        return 0;
    }

    struct coord spos = j->sprite.pos;
    int jx = spos.x;
    int jy = spos.y - spos.z;
    if(jy<0) jy = 0;

    const int *lookup = currentStats.extraRangeBombs ? &bombRadii2 : &bombRadii1;

    struct bomb **B = explodingBombs;
    for(const struct bomb **E = explodingBombs+explodingBombCount; B != E; ++B) {
        struct bomb *b = *B;
        const byte radiusIndex = b->sprite.pattern - BOMB_EXPLOSION_FIRST;
        const int radius = *(lookup+radiusIndex);

        int C = b->sprite.pos.x - radius;
        if(jx < C) continue;
        C += (radius << 1);
        if(jx >= C) continue;
        C = b->sprite.pos.y - radius - 4;
        if(jy < C) continue;
        C += (radius << 1);
        if(jy >= C) continue;

        b->outcome |= BOMB_OUTCOME_JEFF_KILL;
        killJeff(j);
        effectExplosion();

        C = b->sprite.pos.x - (BOMB_CLOSE>>1);
        if(jx < C) return 1;
        C += BOMB_CLOSE;
        if(jx >= C) return 1;
        C = b->sprite.pos.y - (BOMB_CLOSE>>1) - 4;
        if(jy < C) return 1;
        C += BOMB_CLOSE;
        if(jy >= C) return 1;

        status("+10 PTS");
        effectZap();
        currentStats.score += 10;
        return 1;
    }

    return 0;
}

static void jeffWalkStep(struct jeff *restrict j) __z88dk_fastcall {
    byte newPattern = ++(j->sprite.pattern);
    byte direction = j->direction;
    setJeffPos(j, direction);
    switch(direction) {
        case JEFF_UP:
            if((j->sprite.pos.y - j->sprite.pos.z) < 1) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_BACK_LAST) {
                    j->sprite.pattern = JEFF_BACK_FIRST;
                }
            }
            break;

        case JEFF_DOWN:
            if((j->sprite.pos.y - j->sprite.pos.z) > 254) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_FRONT_LAST) {
                    j->sprite.pattern = JEFF_FRONT_FIRST;
                }
            }
            break;

        case JEFF_LEFT:
            if(j->sprite.pos.x == 0) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_SIDE_LAST) {
                    j->sprite.pattern = JEFF_SIDE_FIRST;
                }
            }
            break;

        case JEFF_RIGHT:
            if(j->sprite.pos.x == 320) {
                jeffEscape(j);
            } else {
                if(newPattern > JEFF_SIDE_LAST) {
                    j->sprite.pattern = JEFF_SIDE_FIRST;
                }
            }
            break;
    }
}

static void jeffStandStep(struct jeff *j) __z88dk_fastcall {
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

static void jeffAppearStep(struct jeff *j) __z88dk_fastcall {
    if(++(j->sprite.pattern) > JEFF_APPEAR_LAST) {
        j->state = JEFF_STATE_STAND;
        j->progress = 0;
        jeffStandStep(j);
    }
}

static void resetLanding(void) __z88dk_fastcall {
    hideSprite(landing.sprite.index);
    landing.active = 0;
}

void jeffKillAll(byte retireImmediately) __z88dk_fastcall {
    struct jeff **J = activeJeff;
    for(const struct jeff **E = activeJeff+activeJeffCount; J != E; ++J) {
        struct jeff *j = *J;
        switch(j->state) {
            case JEFF_STATE_STAND:
            case JEFF_STATE_WALK:
                killJeff(j);
            case JEFF_STATE_APPEAR:
            case JEFF_STATE_LANDING:
            case JEFF_STATE_DISAPPEAR:
                if(retireImmediately) {
                    retireJeff(j);
                }
            case JEFF_STATE_NONE:
        }
    }
    if(retireImmediately) {
        resetLanding();
    }
}

static void holdStep(void) __z88dk_fastcall {
    word v = currentStats.holdCount--;
    if(v == 1) {
        status(NULL);
    } else if(v % 50 == 0) {
        sprintf(textBuf, "%d", v / 50);
        status(textBuf);
    }
}

void updateJeffs(void) __z88dk_fastcall {
    if(damageFlash) {
        --damageFlash;
        if(damageFlash == 0 && currentStats.invunerableCount == 0) {
            setFallbackColour(0);
        }
        scrollLayer2((damageFlash % 2), 0);

    } else if(++currentStats.difficultyCountdown == currentStats.difficultyStepInLevel) {
        currentStats.difficultyCountdown = 0;
        if(currentStats.generationPeriod > 10) {
            --currentStats.generationPeriod;
        }
    }

    if(landing.active) {
        struct jeff *j = landing.passenger;
        if(landing.sprite.pattern == LANDING_HIT) {
            j->state = JEFF_STATE_APPEAR;
            updateSprite(&j->sprite);
            resetLanding();
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

    byte canMove;
    if(currentStats.holdCount == 0) {
        if(currentStats.generationCountdown == 0) {
            if(!landing.active) {
                currentStats.generationCountdown = currentStats.generationPeriod;
                launchRandomJeff();
            }
        } else if(currentStats.umbrellaCountdown > 0) {
            --currentStats.umbrellaCountdown;
        } else {
            --currentStats.generationCountdown;
        }

        canMove = 1;
        if(currentStats.slowMo) {
            if(currentStats.sloMoHold) {
                --currentStats.sloMoHold;
                canMove = 0;
            } else {
                currentStats.sloMoHold = 2;
                --currentStats.slowMo;
            }
        }

        if(currentStats.invunerableCount > 0) {
            --currentStats.invunerableCount == 0;
        }

    } else {
        canMove = 0;
        holdStep();
    }

    logicLoop = (logicLoop << 1) | (logicLoop >> 15);

    struct jeff **J = activeJeff;
    for(const struct jeff **E = activeJeff+activeJeffCount; J != E; ++J) {
        struct jeff *j = *J;
        switch(j->state) {
            case JEFF_STATE_STAND:
                if(j->moveMask & logicLoop) {
                    jeffStandStep(j);
                    jeffCheckBombs(j);
                    updateSprite(&j->sprite);
                }
                continue;

            case JEFF_STATE_APPEAR:
                if(JEFF_SPEED_MASK_4 & logicLoop) {
                    jeffAppearStep(j);
                    updateSprite(&j->sprite);
                }
                continue;

            case JEFF_STATE_DISAPPEAR:
                if(JEFF_SPEED_MASK_4 & logicLoop) {
                    if(++(j->sprite.pattern) > JEFF_DISAPPEAR_LAST) {
                        retireJeff(j);
                    } else {
                        updateSprite(&j->sprite);
                    }
                }
                continue;

            case JEFF_STATE_WALK:
                if(canMove && (j->moveMask & logicLoop)) {
                    jeffWalkStep(j);
                    if(j->state != JEFF_STATE_NONE) {
                        jeffCheckBombs(j);
                        updateSprite(&j->sprite);
                    }

                } else if(jeffCheckBombs(j)) {
                    updateSprite(&j->sprite);
                }
                continue;
        }
    }
}
