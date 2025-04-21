#ifndef _LEDS_H_
#define _LEDS_H_

#include "types.h"

void setupTitleLeds(void) __z88dk_fastcall;
void cycleGrayPalette(void) __z88dk_fastcall;
void ulaAttributeClear(void) __z88dk_fastcall;
void ulaAttributeClear(void) __z88dk_fastcall;
void status(const byte *text) __z88dk_fastcall;
void updateStatus(void) __z88dk_fastcall;

#endif
