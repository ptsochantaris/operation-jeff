#ifndef _INTERRUPTS_H_
#define _INTERRUPTS_H_

#include "types.h"

void setupInterrupts(void) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;          // switch from legacy IM1 to hardware IM2
void saveAndDisableInterrupts(void) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void restoreInterrupts(void) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;

#endif
