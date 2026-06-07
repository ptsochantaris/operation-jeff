#ifndef _INTERRUPTS_H_
#define _INTERRUPTS_H_

#include "types.h"

void setupInterrupts(void) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;          // switch from legacy IM1 to hardware IM2
void waitFrame(void) __preserves_regs(a,b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;             // halt until the next ULA frame (CTC-safe); preserves all
byte saveAndDisableInterrupts(void) __preserves_regs(b,c,d,e,h,iyh,iyl) __z88dk_fastcall;  // returns prior IFF state
void restoreInterrupts(byte wasEnabled) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;

#endif
