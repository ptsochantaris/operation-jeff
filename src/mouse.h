#ifndef __MOUSE_H__
#define __MOUSE_H__

typedef struct MouseState {
    byte handled;
    byte ongoing;
    int wheel;
};

extern int mouseX, mouseY, mouseHwB;

extern struct MouseState mouseState;

void mouseInit(void) __z88dk_fastcall;
void updateMouse(void) __z88dk_fastcall;
void hideMouse(void) __z88dk_fastcall;
void setGameMouse(void) __z88dk_fastcall;
void setMenuMouse(void) __z88dk_fastcall;
void mouseReset(void) __z88dk_fastcall;

#endif
