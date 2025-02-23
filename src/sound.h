#ifndef __SOUND_H__
#define __SOUND_H__

#include "music.h"

void ayChipSelect(byte chip) __z88dk_fastcall;
void aySetPitch(word channel, word pitch);
void ayPlayNote(word channel, NoteIndex note);
void aySetEnvelope(word type, word duration);
void aySetNoise(word speed) __z88dk_fastcall;
void aySetMixer(word channel, word tone, word noise);
void aySetAmplitude(word channel, word volume);
void ayStopAllSound(void) __z88dk_fastcall;

#endif
