#ifndef __MENU_H__
#define __MENU_H__

#define SMALL_INPUT_DELAY 50

extern byte inputDelay;

void menuLoop(void) __z88dk_fastcall;
void menuMode(void) __z88dk_fastcall;

#endif
