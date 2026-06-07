#ifndef _KEYBOARD_H_
#define _KEYBOARD_H_

#include "types.h"

extern byte keyboardShiftPressed;
extern byte keyboardSymbolShiftPressed;

byte readKeyboardLetter(void) __preserves_regs(c) __z88dk_fastcall; // clobbers IY (port cursor)

#endif
