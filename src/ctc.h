#ifndef _CTC_H_
#define _CTC_H_

#include "types.h"

// CTC time constants (28MHz/16/TC) per effect, matching the old per-sample DMA
// prescalers: zap/siren were 0x74, sting was 0x3A (half = double rate), menu 109.
#define SAMPLE_TC_8K  219  // ~8kHz  (zap, siren, menu loop)
#define SAMPLE_TC_16K 110  // ~16kHz (sting)

struct ResourceInfo; // defined in assets.h; only used here by pointer

// Page in the sample's MMU1/MMU2 banks and start CTC-driven playback.
void playSample(struct ResourceInfo *restrict info, byte tc, byte loop) __z88dk_callee;

// Low-level CTC sample player (ctc-rw.asm).
void startSample(word source, word length, byte tc, byte loop) __z88dk_callee __smallc; // tc = 28MHz/16/rate
void stopAudioTimer(void) __z88dk_fastcall;
extern volatile byte sampleActive; // 1 while a CTC sample is playing, cleared by the ISR at end

#endif
