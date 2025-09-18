#ifndef _KEYBOARD_H_
#define _KEYBOARD_H_

#include "types.h"

extern byte keyboardShiftPressed;
extern byte keyboardSymbolShiftPressed;

byte readKeyboardLetter(void) __preserves_regs(iyh,iyl) __z88dk_fastcall;

#endif
