#ifndef _INTERRUPTS_H_
#define _INTERRUPTS_H_

#include "types.h"

void setupInterrupts(void) __z88dk_fastcall;          // switch from legacy IM1 to hardware IM2
void waitFrame(void) __z88dk_fastcall;                // halt until the next ULA frame (CTC-safe)
byte saveAndDisableInterrupts(void) __z88dk_fastcall; // returns prior IFF state
void restoreInterrupts(byte wasEnabled) __z88dk_fastcall;

#endif
