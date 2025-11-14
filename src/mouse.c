#include "base.h"

#define MOUSE_PATTERN 9

extern struct MouseState mouseState;
extern struct sprite_info mouseSprite;

void mouseInit(void) __z88dk_fastcall {
    mouseReset();
    mouseX = 159;
    mouseY = 127;
    mouseSprite.pos.x = 159;
    mouseSprite.pos.y = 127;
    updateSprite(&mouseSprite);
}

void endMouse(void) __z88dk_fastcall {
    hideSprite(127);
}

void mouseReset(void) __z88dk_fastcall {
    mouseSprite.pattern = MOUSE_PATTERN;
    mouseSprite.index = 127;
    mouseState.handled = 1;
    mouseState.ongoing = 0;
    mouseState.wheel = 0;
}

extern struct coord mouseTopLeft;

void setGameMouse(void) __z88dk_fastcall {
    mouseReset();
    mouseTopLeft.x = 16;
    mouseTopLeft.y = 16;
}

void setMenuMouse(void) __z88dk_fastcall {
    mouseReset();
    mouseTopLeft.x = 0;
    mouseTopLeft.y = 0;
}

/*
mouseSprite.pos.x = mouseX;
mouseSprite.pos.y = mouseY;

updateSprite(&mouseSprite);

int wheel = mouseHwB >> 4; // wheel WWWW0000
int wheelDiff = wheel - currentWheel;
currentWheel = wheel;
if(wheelDiff < 10 && wheelDiff > -10) {
    mouseState.wheel += wheelDiff;
}
    
    word click = mouseHwB & 2; // left click 000000LR
    if(mouseState.ongoing) {
        if(click != 0) {
            mouseState.ongoing = 0;
        }
    } else if(click == 0) { 
        mouseState.handled = 0;
        mouseState.ongoing = 1;
    }
*/
