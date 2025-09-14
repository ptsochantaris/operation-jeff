#ifndef _SPRITES_H_
#define _SPRITES_H_

typedef struct sprite_info {
    byte index;
    struct coord pos;
    byte scaleUp;
    byte horizontalMirror;
    byte pattern;
};

void loadSprites(void) __z88dk_fastcall;
void setSpriteGameClipping(void) __z88dk_fastcall;
void setSpriteMenuClipping(void) __z88dk_fastcall;

#endif
