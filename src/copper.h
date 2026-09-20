#ifndef __OJ_COPPER_H__
#define __OJ_COPPER_H__

// Per-power-up cloud tints for copperEffectCloud(...): low, mid, high anchors plus
// the palette split - how many of the 64 entries the low -> mid leg gets before
// mid -> high takes over. 32 is an even division; a smaller number makes the first
// leg a short accent and hands the rest of the palette to the base. Both legs need
// at least 2 entries. See buildPlasmaPalette in copper.c for why the split is
// per-tint, and for why an accent belongs at the low end rather than the high one.
#define SHIELD_CLOUD    RGB332(0, 0, 1), RGB332(0, 0, 7), RGB332(1, 1, 6), 32
#define UMBRELLA_CLOUD  RGB332(1, 0, 1), RGB332(3, 0, 2), RGB332(3, 0, 2), 32
#define GUNBOOST_CLOUD  RGB332(1, 1, 0), RGB332(5, 3, 0), RGB332(5, 3, 0), 32
// Extra range, kept in the supergun's warm family but a step brighter and cleaner:
// a flat vivid orange base with narrow black bands through it. The kernel indexes
// the palette with sine[ia]+sine[ib], and that sum is only ~2-4x less likely at the
// ends than at its peak, so a low anchor is a narrow accent rather than a rarity -
// measured at 6.6% of bands near-black here, against 2.1% for GUNBOOST_CLOUD.
// mid == high flattens the upper half, which is what leaves the orange as a base
// rather than a ramp.
#define RANGE_CLOUD     RGB332(0, 0, 0), RGB332(7, 3, 0), RGB332(7, 3, 0), 32
#define SLOW_CLOUD      RGB332(1, 1, 0), RGB332(4, 4, 0), RGB332(4, 4, 0), 32
// Flat icy blue with off-white highlights. low == mid is what keeps it calm: it
// flattens the whole lower half of the palette into one colour, so the cloud is a
// broad even field with a few pale bands through it rather than a stack of stripes.
// (Every settled tint has a flat half - the others get it from mid == high.) The
// tip stays (6,7,3) rather than (7,7,3) so the brightest bands keep a cold cast.
// Counting colour changes down the 288 bands: 18 per frame, against 44 for the
// first version of this tint which ramped up from a dark blue as well.
#define ICE_CLOUD       RGB332(3, 5, 3), RGB332(3, 5, 3), RGB332(6, 7, 3), 32
// Horseshoe magnet: a deep red field with short white highlights cutting through it.
// The whole tint is that 6 - white sits at the low end, where every palette entry is
// live, and reaches the red within six of them, so the transition is a couple of
// scanlines rather than the wide pastel ramp a 32-entry leg produces. That ramp is
// what made earlier versions read as strawberry: measured over a run of frames this
// is 96% dark red, 2% white and 2% in between, against 77/0/16 for the bright red
// and silver version, and 8 band changes per frame against 35.
#define MAGNET_CLOUD    RGB332(7, 7, 3), RGB332(4, 0, 0), RGB332(4, 0, 0), 6

void copperInit(void) __z88dk_fastcall;

// `level` is how much of the bonus is left, 0..255 of its reserve: the cloud's
// height tracks it, so it opens on pickup and narrows as the bonus is spent.

// Pass CLOUD_FULL for a bonus with nothing to count down.
#define CLOUD_FULL 255

void copperEffectCloud(byte low, byte mid, byte high, byte split, byte level) __z88dk_callee;
void copperEffectFire(void) __z88dk_fastcall;
void copperEffectFlash(void) __z88dk_fastcall;
void copperEffectClose(void) __z88dk_fastcall; // animated stop, needs copperEffectUpdate to keep running
void copperEffectOff(void) __z88dk_fastcall;   // immediate stop, safe to call and then walk away
void copperEffectUpdate(void) __z88dk_fastcall;

#endif
