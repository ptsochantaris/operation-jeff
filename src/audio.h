#ifndef __AUDIO_H__
#define __AUDIO_H__

#include "types.h"

void ayChipSelect(byte chip) __preserves_regs(d,e,h,l,iyh,iyl) __z88dk_fastcall;
void aySetNoise(byte speed) __preserves_regs(d,e,h,l,iyh,iyl) __z88dk_fastcall;
void aySetPitch(byte channel, word pitch) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void aySetAmplitude(byte channel, byte volume) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void aySetEnvelope(byte type, word duration) __z88dk_callee __smallc;
void aySetMixer(byte channel, byte tone, byte noise) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;

#endif
