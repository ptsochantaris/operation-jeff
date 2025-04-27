#ifndef __MOUSE_H__
#define __MOUSE_H__

typedef struct MouseState {
    struct coord pos;
    byte handled;
    byte ongoing;
    int wheel;
};

extern struct MouseState mouseState;

void mouseInit(void) __z88dk_fastcall;
void updateMouse(void) __z88dk_fastcall;
void hideMouse(void) __z88dk_fastcall;
void setGameMouse(void) __z88dk_fastcall;
void setMenuMouse(void) __z88dk_fastcall;
void mouseReset(void) __z88dk_fastcall;

#endif
