#include "base.h"

#define stripeX ((46 & 0x3F) << 1)

// --------------------------------------------------------------- Utility

static byte copperImage[1200];

static void uploadCopperImage(word len) __z88dk_fastcall {
    copperAddress(0);
    z80_outp(0x243b, REG_COPPER_DATA);
    if (copperDmaResident) {
        dmaRepeat();
    } else {
        dmaMemoryToPort(copperImage, 0x253b, len); // full setup (clears the flag)...
        copperDmaResident = 1;                     // ...now resident
    }
}

// --------------------------------------------------------------- Flash

#define STRIPECOUNT   60
#define STRIPESIZE    4
#define STRIPE_BYTES  4
#define LEGACY_OFFSET 34
#define FLASH_BG      0x60   // red field shown when the player takes damage
#define FLASH_SPARK   0xFC   // bright spark base colour

// Emit one stripe (WAIT + MOVE colour) into the copper image, set up during the
// blanking of the line above `y`.
static void emitStripe(byte **pp, byte colour, word y) __z88dk_callee {
    word waitY = y - 1;
    byte *p = *pp;
    p[0] = 0x80 | stripeX | ((waitY >> 8) & 1); // wait (high)
    p[1] = waitY & 0xFF;                        // wait (low)
    p[2] = 0x4A;                                // move: fallback colour register
    p[3] = colour;
    *pp = p + 4;
}

#define FLASH_BUFFER_LEN 12
static void buildFlashSkeleton(void) __z88dk_fastcall {
    byte *p = copperImage;
    p[0] = 0x4A;                                // move: fallback colour register
    p[1] = FLASH_BG;                            // bg color

    p[2] = 0;                                   // wait for scanline high
    p[3] = 0;                                   // wait for scanline low

    p[4] = 0x4A;                                // move: fallback colour register
    p[5] = 0;                                   // spark color

    p[6] = 0;                                   // wait
    p[7] = 0;                                   // for scanline

    p[8] = 0x4A;                                // move: fallback colour register
    p[9] = FLASH_BG;                            // bg color

    p[10] = 0xFF;
    p[11] = 0xFF; // wait for vblank / halt

    copperDmaResident = 0; // layout/length changed -> force a full re-prime next upload
}

// Per-frame: clear the previous spark and place a new random bright one.
static void flashCycle(void) __z88dk_fastcall {
    word c = random16() % (STRIPECOUNT - 2);
    word sparkPos = (c * 8) - 1;

    // start of colour
    copperImage[2] = 0x80 | stripeX | ((sparkPos >> 8) & 1);
    copperImage[3] = sparkPos & 0xFF;

    copperImage[5] = FLASH_SPARK + (random16() % 4);

    // end of colour
    sparkPos += 1 + random16() % 8;
    copperImage[6] = 0x80 | stripeX | ((sparkPos >> 8) & 1);
    copperImage[7] = sparkPos & 0xFF;

    uploadCopperImage(FLASH_BUFFER_LEN);
}

// --------------------------------------------------------------- Plasma

#define PLASMA_TOP_LINE   1     // first raster line of the effect region
#define PLASMA_LINES      288    // full-height bands (one transition each)
#define COL0_HPOS         46     // each band is set during the previous line's blanking
#define VERTICAL_OFFSET   50

// plasma shape: how fast the colour varies down the screen, and animation speed.
// GY_A/GY_B are the per-band steps through the sine table; the inner loop lives in
// copper-rw.asm now, so changing either means changing the `inc d` / `inc e` counts
// there too. PLASMA_LINES must stay a multiple of the kernel's group size (8).
#define GY_A 3
#define GY_B 1

#define PLASMA_PAL_SIZE   64

// one transition per band, plus a leading/trailing "black" to blank above/below
#define PLASMA_BUFFER_LEN  ((PLASMA_LINES + 2) * 4 + 2)
#define PLASMA_FIRST_COLOUR 7    // first band colour slot (after the leading black transition)


// Fill the palette slice dst[0..count) by interpolating the two RRRGGGBB anchors
// per channel. Each channel walks in 8.8 fixed point, so a ramp costs just 3
// divides total (one per-step delta per channel) instead of the old signed
// mul+div per channel per entry. Matches the previous lerp within +/-1 per
// channel (round-to-nearest vs truncate); endpoints are exact, drift invisible.
static void rampPalette(byte *dst, byte count, byte from, byte to) __z88dk_callee {
    byte steps = count - 1;                 // t spans 0..steps inclusive

    // 8.8 fixed-point channel accumulators, pre-biased by 1/2 so >>8 rounds
    word r = ((word)((from >> 5) & 7) << 8) + 128;
    word g = ((word)((from >> 2) & 7) << 8) + 128;
    word b = ((word)( from       & 3) << 8) + 128;

    int dr = (((int)((to >> 5) & 7) - (int)((from >> 5) & 7)) << 8) / steps;
    int dg = (((int)((to >> 2) & 7) - (int)((from >> 2) & 7)) << 8) / steps;
    int db = (((int)( to       & 3) - (int)( from       & 3)) << 8) / steps;

    for (byte i = 0; i <= steps; ++i) {
        dst[i] = RGB332((r >> 8) & 7, (g >> 8) & 7, (b >> 8) & 3);
        r += dr; g += dg; b += db;
    }
}

// Every table the two kernels index by page lives in one block, carved up at
// runtime. They each have to start on a page boundary so the kernel can reach them
// with `ld l,index` (or `ld c,index`) against a fixed high byte, and z80asm's ALIGN
// is no help: it aligns within the module's own section frame, not the linked
// address, so a probe placed with ALIGN 256 in bss_compiler still lands mid-page.
// Over-allocating by 255 and aligning at runtime is reliable instead - and sharing
// one block means paying that slack once rather than per table.
//
//   page P+0  plasma sine copy   (256)
//   page P+1  fire colour ramp   (256)
//   page P+2  plasma palette     (64, remainder unused)
#define COPPER_TABLE_BYTES (256 + 256 + PLASMA_PAL_SIZE + 255)
static byte copperTables[COPPER_TABLE_BYTES];
static byte *plasmaSine;    // page P+0
static byte *fireColour;    // page P+1
static byte *plasmaPalette; // page P+2

void plasmaFill(byte *dst, byte *sine, word indices) __z88dk_callee __smallc;

// Idempotent; called from whichever effect starts first.
static void alignCopperTables(void) __z88dk_fastcall {
    plasmaSine    = (byte *)(((word)copperTables + 255) & 0xFF00);
    fireColour    = plasmaSine + 256;
    plasmaPalette = plasmaSine + 512;
}

// Build the 64-entry cloud palette by interpolating low -> mid across the lower
// half and mid -> high across the upper half. Anchors are 8-bit RRRGGGBB; pass
// different triples to tint the cloud per bonus.
static void buildPlasmaPalette(byte low, byte mid, byte high) __z88dk_callee {
    byte half = PLASMA_PAL_SIZE / 2;
    rampPalette(plasmaPalette,        half, low, mid);
    rampPalette(plasmaPalette + half, half, mid, high);
}

static void emitTransition(byte **pp, byte hpos, word waitLine) __z88dk_callee {
    byte *p = *pp;
    p[0] = 0x80 | (hpos << 1) | ((waitLine >> 8) & 1);
    p[1] = waitLine & 0xFF;
    p[2] = 0x4A;
    p[3] = 0; // colour, filled per frame
    *pp = p + 4;
}

static void buildPlasmaSkeleton(void) __z88dk_fastcall {
    byte *p = copperImage;

    // leading black: blanks everything above the frame (colour stays 0, never updated)
    emitTransition(&p, 0, 0);

    // one band per scanline, set during the previous line's blanking
    for (word i = 0; i < PLASMA_LINES; ++i) {
        word abs = PLASMA_TOP_LINE + i;
        emitTransition(&p, COL0_HPOS, abs - 1);
    }

    // trailing black: blanks everything below the frame (set in the last line's blanking)
    emitTransition(&p, COL0_HPOS, PLASMA_TOP_LINE + PLASMA_LINES - 1);

    // halt until the copper is reset at the next frame edge
    p[0] = 0xFF;
    p[1] = 0xFF;

    copperDmaResident = 0; // layout/length changed -> force a full re-prime next upload
}

// precomputed (sin(i * 2pi/256) + 1) * 15.5, range 0..31
static const byte sineTab[256] = {
    15, 15, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 21,
    21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 25, 26,
    26, 26, 26, 27, 27, 27, 27, 28, 28, 28, 28, 28, 29, 29, 29, 29,
    29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
    31, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29,
    29, 29, 29, 29, 29, 28, 28, 28, 28, 28, 27, 27, 27, 27, 26, 26,
    26, 26, 25, 25, 25, 25, 24, 24, 24, 23, 23, 23, 22, 22, 22, 21,
    21, 21, 20, 20, 19, 19, 19, 18, 18, 18, 17, 17, 17, 16, 16, 15,
    15, 15, 14, 14, 13, 13, 13, 12, 12, 12, 11, 11, 11, 10, 10,  9,
     9,  9,  8,  8,  8,  7,  7,  7,  6,  6,  6,  5,  5,  5,  5,  4,
     4,  4,  4,  3,  3,  3,  3,  2,  2,  2,  2,  2,  1,  1,  1,  1,
     1,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,
     1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  3,  3,  4,  4,
     4,  4,  5,  5,  5,  5,  6,  6,  6,  7,  7,  7,  8,  8,  8,  9,
     9,  9, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 15,
};

static byte plasmaTimeA = 0;
static byte plasmaTimeB = 0;

// Seed the RAM-side sine copy the kernel indexes. Called when the cloud effect
// starts, not per frame.
static void alignPlasmaTables(void) __z88dk_fastcall {
    alignCopperTables();
    for (word i = 0; i < 256; ++i) {
        plasmaSine[i] = sineTab[i];
    }
}

static void copperPlasmaUpdate(void) __z88dk_fastcall {
    plasmaTimeA += 1;
    plasmaTimeB += 3;

    // ia = gy*GY_A + timeA, ib = gy*GY_B - timeB, gy = 0; packed high/low for the
    // kernel, which walks them by GY_A and GY_B respectively.
    word indices = ((word)plasmaTimeA << 8) | (byte)(-plasmaTimeB);

    // skip the leading black; each transition is 4 bytes
    plasmaFill(copperImage + PLASMA_FIRST_COLOUR, plasmaSine, indices);
    uploadCopperImage(PLASMA_BUFFER_LEN);
}

// --------------------------------------------------------------- Fire

// Fire drives the artwork's border palette entry (HUD_MASK) instead of the
// transparency fallback, so the flames render on the opaque border pixels inside the
// image - no overscan, and the horizontal shape is defined by the artwork. Each band
// is WAIT + MOVE index + MOVE value = 6 bytes; the index is re-set every line so the
// palette auto-increment can stay enabled (no global side effect on other uploads).
#define FIRE_BAND_BYTES    6
#define FIRE_FIRST_COLOUR  5     // value byte within the first band
#define FIRE_BAND_HEIGHT   2     // scanlines per fire band (vertical resolution)
#define FIRE_TOP_LINE      1     // first raster line of the fire
#define FIRE_LINES         288   // cover the layer 2 area only (no hardware border)
// 144. The fire kernel in copper-rw.asm is unrolled against this exact count
// (FIRE_GROUPS x 8, then a 7-band tail, then the undrawn bottom band); changing
// FIRE_LINES or FIRE_BAND_HEIGHT means re-deriving that split there.
#define FIRE_BANDS         (FIRE_LINES / FIRE_BAND_HEIGHT)
#define FIRE_BUFFER_LEN    (FIRE_BANDS * FIRE_BAND_BYTES + 2)
#define FIRE_SEED_ROWS      2   // bottom bands reseeded hot each frame (~4px base at 2px/band)

// fire variant: same band pipeline, different per-line colour source. The ramp is
// expanded to 256 entries (4 identical entries per ramp step) so the per-band draw
// indexes it with the raw heat and skips the >>2; it lives in the shared aligned
// block above so the kernel reaches it with `ld c,heat` against a fixed page in B.
// The heat buffer needs no alignment - the kernel walks it as a plain pointer.
static byte fireBuf[FIRE_BANDS];

void fireFill(byte *dst, byte *colour, byte *buf) __z88dk_callee __smallc;

static void buildFirePalette(void) __z88dk_fastcall {
    alignCopperTables();

    // Black -> red -> orange -> yellow -> white (RRRGGGBB). Tunable.
    byte *d = fireColour;
    for (byte i = 0; i < PLASMA_PAL_SIZE; ++i) {
        byte r = (i < 24) ? (byte)((i * 7) / 24) : 7;        // red ramps in first, then holds
        byte g = (i < 16) ? 0 : (byte)(((i - 16) * 7) / 47); // green builds -> yellow
        byte b = (i < 48) ? 0 : (byte)(((i - 48) * 3) / 15); // blue only at the hot tip -> white
        byte c = (r << 5) | (g << 2) | b;
        *d++ = c; *d++ = c; *d++ = c; *d++ = c;              // heat 0..255 -> ramp step 0..63
    }
}

static void fireSeed(void) __z88dk_fastcall {
    // reseed the bottom rows hot, with a wide range (128..255) so flame heights vary:
    // the hottest seeds climb to the top, weaker ones fade around mid-screen.
    // (The k = 1 row is immediately overwritten by the propagation below it, but the
    // draw still has to happen: random16 is shared, so dropping it would shift the
    // whole stream and change every effect downstream.)
    for (byte k = 0; k < FIRE_SEED_ROWS; ++k) {
        fireBuf[FIRE_BANDS - 1 - k] = (byte)(128 + (random16() & 127));
    }
}
// The upward propagation that used to live here - each band cooling from the band
// below it, 2 random bits per band, a fresh random16 every 8 bands - is now fused
// with the copper write in fireFill (copper-rw.asm), which halves the walks over
// the band array from two to one.

static void buildFireSkeleton(void) __z88dk_fastcall {
    byte *p = copperImage;
    for (word i = 0; i < FIRE_BANDS; ++i) {
        word waitLine = FIRE_TOP_LINE + i * FIRE_BAND_HEIGHT - 1; // set during the blanking above the band
        p[0] = 0x80 | (COL0_HPOS << 1) | ((waitLine >> 8) & 1);
        p[1] = waitLine & 0xFF;
        p[2] = REG_PALETTE_INDEX;   // MOVE: select the border colour slot...
        p[3] = HUD_MASK;
        p[4] = REG_PALETTE_VALUE_8; // ...and set its colour (RGB332), filled per frame
        p[5] = 0;
        p += FIRE_BAND_BYTES;
    }
    p[0] = 0xFF;
    p[1] = 0xFF; // halt until the copper resets at the next frame edge

    copperDmaResident = 0; // layout/length changed -> force a full re-prime next upload
}

static void copperFireUpdate(void) __z88dk_fastcall {
    fireSeed();
    fireFill(copperImage + FIRE_FIRST_COLOUR, fireColour, fireBuf);
    uploadCopperImage(FIRE_BUFFER_LEN);
}

// --------------------------------------------------------------- Public functions

#define FX_NONE  0
#define FX_CLOUD 1
#define FX_FIRE  2
#define FX_FLASH 3

static byte fxMode = FX_NONE;
static byte fxLow, fxMid, fxHigh;

void copperInit(void) __z88dk_fastcall {
    copperStop();
    ZXN_NEXTREG(0x4a, 0);  // black fallback colour until an effect runs
    fxMode = FX_NONE;
}

void copperEffectCloud(byte low, byte mid, byte high) __z88dk_callee {
    if (fxMode == FX_CLOUD && low == fxLow && mid == fxMid && high == fxHigh) return;
    fxMode = FX_CLOUD;
    fxLow = low; fxMid = mid; fxHigh = high;
    copperStop();
    ZXN_NEXTREG(0x64, VERTICAL_OFFSET);
    alignPlasmaTables();
    buildPlasmaPalette(low, mid, high);
    buildPlasmaSkeleton();
    copperPlasmaUpdate(); // fill colours, upload, start the copper
}

void copperEffectFire(void) __z88dk_fastcall {
    if (fxMode == FX_FIRE) return;

    fxMode = FX_FIRE;
    copperStop();
    ZXN_NEXTREG(0x64, VERTICAL_OFFSET);
    selectPalette(1); // copper MOVEs target the layer 2 palette (border colour slot)
    buildFirePalette();
    buildFireSkeleton();

    copperFireUpdate();
}

void copperEffectFlash(void) __z88dk_fastcall {
    if (fxMode == FX_FLASH) return;

    fxMode = FX_FLASH;
    copperStop();
    ZXN_NEXTREG(0x64, LEGACY_OFFSET); // offset copper up from ULA zero
    buildFlashSkeleton();
    uploadCopperImage(FLASH_BUFFER_LEN); // DMA the skeleton up and start the copper from index 0
}

void copperEffectOff(void) __z88dk_fastcall {
    if (fxMode == FX_NONE) return;
    
    fxMode = FX_NONE;
    copperStop();
    ZXN_NEXTREG(0x4a, 0);
}

void copperEffectUpdate(void) __z88dk_fastcall {
    switch (fxMode) {
        case FX_CLOUD: copperPlasmaUpdate(); break;
        case FX_FIRE:  copperFireUpdate();  break;
        case FX_FLASH: flashCycle();        break;
    }
}
