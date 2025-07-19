#ifndef __BOMB_H__
#define __BOMB_H__

#define BOMB_STATE_NONE 0
#define BOMB_STATE_TICKING 1
#define BOMB_STATE_EXPLODING 2

#define BOMB_OUTCOME_NONE 0
#define BOMB_OUTCOME_JEFF_KILL 1
#define BOMB_OUTCOME_BONUS_HIT 2

#define bombCount 20

typedef struct bomb {
    struct coord target;
    byte outcome;
    byte state;
    byte countdown;
    struct sprite_info sprite;
};

extern struct bomb bombs[];

extern struct bomb* explodingBombs[];
extern byte explodingBombCount;

void initBombs(void) __z88dk_fastcall;
void updateBombs(void) __z88dk_fastcall;
void resetAllBombs(void) __z88dk_fastcall;
void bombsFlashAll(void) __z88dk_fastcall;
void bombsRestoreFromFlash(void) __z88dk_fastcall;

#endif
