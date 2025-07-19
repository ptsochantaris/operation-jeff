#ifndef _SPRITES_H_
#define _SPRITES_H_

typedef struct sprite_info {
    byte index;
    struct coord pos;
    byte pattern;
    byte horizontalMirror;
    byte scaleUp;
};

void loadSprites(void) __z88dk_fastcall;
void updateSprite(struct sprite_info *restrict s) __z88dk_fastcall;
void hideSprite(byte index) __z88dk_fastcall;
void setSpriteGameClipping(void) __z88dk_fastcall;
void setSpriteMenuClipping(void) __z88dk_fastcall;

#endif
