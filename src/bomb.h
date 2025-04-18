#ifndef __BOMB_H__
#define __BOMB_H__

#define BOMB_STATE_NONE 0
#define BOMB_STATE_TICKING 1
#define BOMB_STATE_EXPLODING 2

#define bombCount 20

typedef struct {
    coord target;
    byte state;
    byte countdown;
    sprite_info sprite;
} bomb;

extern bomb bombs[];

void initBombs(void) __z88dk_fastcall;
void updateBombs(void) __z88dk_fastcall;

#endif
