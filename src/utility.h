#ifndef _UTILITY_H_
#define _UTILITY_H_

#include "types.h"

word random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void srand16(word seed) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void stackClear(word base, word len, byte pattern) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void copperAddress(word address) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;
void copperStop(void) __preserves_regs(b,c,d,e,h,l,iyh,iyl) __z88dk_fastcall;
void setupInterrupts(void) __z88dk_fastcall;
void startSample(word source, word length, byte tc, byte loop) __z88dk_callee __smallc; // CTC sample playback (tc = 28MHz/16/rate)
void stopAudioTimer(void) __z88dk_fastcall;
void waitFrame(void) __z88dk_fastcall; // halt until the next ULA frame (CTC-safe)
byte saveAndDisableInterrupts(void) __z88dk_fastcall; // returns prior IFF state
void restoreInterrupts(byte wasEnabled) __z88dk_fastcall;
extern volatile byte sampleActive;     // 1 while a CTC sample is playing, cleared by the ISR at end

#endif
