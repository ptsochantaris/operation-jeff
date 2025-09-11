#ifndef __SOUND_H__
#define __SOUND_H__

#include "music.h"

void ayChipSelect(byte chip) __preserves_regs(d,e,h,iyh,iyl) __z88dk_fastcall;
void aySetNoise(byte speed) __preserves_regs(d,e,h,iyh,iyl) __z88dk_fastcall;
void aySetPitch(byte channel, word pitch) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void aySetAmplitude(byte channel, byte volume) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
void aySetEnvelope(byte type, word duration) __z88dk_callee __smallc;
void aySetMixer(byte channel, byte tone, byte noise) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;

void ayPlayNote(byte channel, enum NoteIndex note) __z88dk_callee;
void ayStopSoundOnChip(byte ayChip) __z88dk_fastcall;
void ayStopAllSound(void) __z88dk_fastcall;

#endif
