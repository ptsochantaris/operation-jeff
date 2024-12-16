#include "resources.h"

#define MOUSE_PATTERN 9

mouseClick mouseClicked = { {0, 0}, 1 ,0 };

static coord previousPos = { 0, 0 };
static sprite_info mouseSprite;
static int currentWheel = 0;
static coord mouseTopLeft = { 0, 0 };

void mouseInit(void) __z88dk_fastcall {
    mouseReset();
    mouseClicked.pos.x = 159;
    mouseSprite.pos.x = 159;
    mouseClicked.pos.y = 127;
    mouseSprite.pos.y = 127;
    updateSprite(&mouseSprite);
}

void endMouse(void) __z88dk_fastcall {
    hideSprite(127);
}

void mouseReset(void) __z88dk_fastcall {
    mouseSprite.pattern = MOUSE_PATTERN;
    mouseSprite.index = 127;
    mouseSprite.attrs = 0;
    mouseClicked.handled = 1;
    mouseClicked.wheel = 0;
}

void setGameMouse(void) __z88dk_fastcall {
    mouseReset();
    if(mouseTopLeft.x < 16) {
        mouseTopLeft.x = 16;
    }
    if(mouseTopLeft.y < 16) {
        mouseTopLeft.y = 16;
    }
}

void setMenuMouse(void) __z88dk_fastcall {
    mouseReset();
}

void updateMouse(void) __z88dk_fastcall {
    int newX = z80_inp(0xfbdf);
    int vx = newX - previousPos.x;
    previousPos.x = newX;
    if(vx < 100 && vx > -100) {
        mouseSprite.pos.x += vx;
        if(mouseSprite.pos.x < mouseTopLeft.x) mouseSprite.pos.x = mouseTopLeft.x;
        else if(mouseSprite.pos.x > 304) mouseSprite.pos.x = 304;
    }

    int newY = z80_inp(0xffdf);
    int vy = previousPos.y - newY;
    previousPos.y = newY;
    if(vy < 100 && vy > -100) {
        mouseSprite.pos.y += vy;
        if(mouseSprite.pos.y < mouseTopLeft.y) mouseSprite.pos.y = mouseTopLeft.y;
        else if(mouseSprite.pos.y > 240) mouseSprite.pos.y = 240;
    }

    updateSprite(&mouseSprite);

    mouseClicked.pos = mouseSprite.pos;

    byte buttons = z80_inp(0xfadf);
    int wheel = buttons >> 4; // wheel WWWW0000
    int wheelDiff = wheel - currentWheel;
    currentWheel = wheel;
    if(wheelDiff < 10 && wheelDiff > -10) {
        mouseClicked.wheel += wheelDiff;
    }
    
    byte click = buttons & 2; // left click 000000LR
    if(mouseClicked.ongoing) {
        if(click != 0) {
            mouseClicked.ongoing = 0;
        }
    } else if(click == 0) { 
        mouseClicked.handled = 0;
        mouseClicked.ongoing = 1;
    }
}