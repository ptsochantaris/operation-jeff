#ifndef __SOUND_H__
#define __SOUND_H__

#include "music.h"

void ayChipSelect(byte chip) __z88dk_fastcall;
void aySetPitch(word channel, word pitch) __z88dk_callee;
void ayPlayNote(word channel, NoteIndex note) __z88dk_callee;
void aySetEnvelope(word type, word duration) __z88dk_callee;
void aySetNoise(word speed) __z88dk_fastcall;
void aySetMixer(word channel, word tone, word noise) __z88dk_callee;
void aySetAmplitude(word channel, word volume) __z88dk_callee;
void ayStopAllSound(void) __z88dk_fastcall;

#endif
