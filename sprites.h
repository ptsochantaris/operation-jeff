#ifndef _SPRITES_H_
#define _SPRITES_H_

typedef struct {
    byte index;
    coord pos;
    byte pattern;
    byte attrs;
} sprite_info;

void loadSprites(void) __z88dk_fastcall;
void updateSprite(sprite_info *restrict s) __z88dk_fastcall;
void hideSprite(byte index) __z88dk_fastcall;
void setSpriteGameClipping(void) __z88dk_fastcall;
void setSpriteMenuClipping(void) __z88dk_fastcall;

#endif
