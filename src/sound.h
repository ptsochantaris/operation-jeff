#ifndef __SOUND_H__
#define __SOUND_H__

#include "music.h"

void ayPlayNote(byte channel, enum NoteIndex note) __z88dk_callee;
void ayStopSoundOnChip(byte ayChip) __z88dk_fastcall;
void ayStopAllSound(void) __z88dk_fastcall;

#endif
