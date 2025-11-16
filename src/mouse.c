#include "base.h"

extern struct MouseState mouseState;

void endMouse(void) __z88dk_fastcall {
    hideSprite(127);
}

void mouseReset(void) __z88dk_fastcall {
    mouseState.handled = 1;
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
