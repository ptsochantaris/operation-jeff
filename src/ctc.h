#ifndef _CTC_H_
#define _CTC_H_

#include "types.h"

#define SAMPLE_TC_8K  219  // ~8kHz  (zap, siren, menu loop)
#define SAMPLE_TC_16K 110  // ~16kHz (sting)

struct ResourceInfo; // defined in assets.h; only used here by pointer

void playSample(struct ResourceInfo *restrict info, byte tc, byte loop) __z88dk_callee;
void startSample(word source, word length, byte tc, byte loop) __z88dk_callee __smallc; // tc = 28MHz/16/rate
void stopAudioTimer(void) __z88dk_fastcall;

extern volatile byte sampleActive; // 1 while a CTC sample is playing, cleared by the ISR at end

#endif
