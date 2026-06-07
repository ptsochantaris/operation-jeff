#include "base.h"

// C-side entry to the CTC sample player: page the sample's banks into the
// MMU1/MMU2 window (Option A: audio owns those banks while playing) and kick
// off the timer-driven streaming in ctc-rw.asm.
void playSample(struct ResourceInfo *restrict info, byte tc, byte loop) __z88dk_callee __smallc {
  ZXN_WRITE_MMU1(info->page);
  ZXN_WRITE_MMU2((info->page)+1);
  startSample((word)info->resource, info->length, tc, loop);
}
