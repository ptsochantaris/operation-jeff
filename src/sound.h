#ifndef __SOUND_H__
#define __SOUND_H__

#include "music.h"

void ayChipSelect(byte chip) __z88dk_fastcall;
void aySetPitch(byte channel, word pitch) __z88dk_callee;
void ayPlayNote(byte channel, enum NoteIndex note) __z88dk_callee;
void aySetEnvelope(byte type, word duration) __z88dk_callee;
void aySetNoise(byte speed) __z88dk_fastcall;
void aySetMixer(byte channel, byte tone, byte noise) __z88dk_callee;
void aySetAmplitude(byte channel, byte volume) __z88dk_callee;
void ayStopSoundOnChip(byte ayChip) __z88dk_fastcall;
void ayStopAllSound(void) __z88dk_fastcall;

#endif
