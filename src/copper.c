#include "base.h"

#define stripeX ((46 & 0x3F) << 1)

static void stripe(byte colour, word y) __z88dk_callee {
    // Set the colour up during the blanking of the line above `y`.
    word waitY = y - 1;
    byte Y1 = (waitY >> 8) & 1;
    byte Y2 = waitY & 0xFF;

    // wait
    ZXN_NEXTREGA(REG_COPPER_DATA, 0x80 | stripeX | Y1);
    ZXN_NEXTREGA(REG_COPPER_DATA, Y2);

    // move
    ZXN_NEXTREG(REG_COPPER_DATA, 0x4A);
    ZXN_NEXTREGA(REG_COPPER_DATA, colour);
}

#define STRIPECOUNT   60
#define STRIPESIZE    4
#define LEGACY_OFFSET 34
#define FLASH_BG      0x60   // red field shown when the player takes damage
#define FLASH_SPARK   0xFC   // bright spark base colour

static word flashCyclePos = 7;

// (Re)build the 60-stripe copper program. The cloud/fire effects overwrite copper
// memory via DMA, so this skeleton must be rebuilt whenever the flash reactivates.
static void buildLegacySkeleton(void) {
    copperStop();
    ZXN_NEXTREG(0x64, LEGACY_OFFSET); // offset copper up from ULA zero

    for(word y = 0; y < STRIPECOUNT; ++y) {
        word top = y*STRIPESIZE+22;
        stripe(0, top);
        stripe(0, top + (STRIPESIZE / 2));
    }

    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF);
    ZXN_NEXTREG(REG_COPPER_DATA, 0xFF); // wait for vblank
}

// Per-frame: clear the previous spark and place a new random bright one.
static void flashCycle(void) {
    copperAddress(flashCyclePos);
    ZXN_NEXTREGA(REG_COPPER_DATA, 0);

    word c = random16() % (STRIPECOUNT - 2);
    flashCyclePos = (c * 8) - 1;
    byte color = FLASH_SPARK + (random16() % 4);
    copperAddress(flashCyclePos);
    ZXN_NEXTREGA(REG_COPPER_DATA, color);
}

// ---------------------------------------------------------------------------
// Plasma / cloud background effect (phase 1: standalone test harness)
//
// Full-height horizontal bands: one change to the global fallback colour
// (reg 0x4A) per scanline, giving a solid colour across the whole width that
// varies (and animates) down the screen. The colour comes from a 1D summed-sine
// plasma each frame, and the whole program is streamed into copper memory via
// DMA at frame start - the same pattern uploadPalette() uses for the palette
// nextreg (screen.c).
//
// Driven through the effect controller at the bottom of this file.
// ---------------------------------------------------------------------------

#define PLASMA_TOP_LINE   1     // first raster line of the effect region
#define PLASMA_LINES      288    // full-height bands (one transition each)
#define COL0_HPOS         46     // each band is set during the previous line's blanking
#define VERTICAL_OFFSET   50

// plasma shape: how fast the colour varies down the screen, and animation speed
#define GY_A 3
#define GY_B 2

#define PLASMA_PAL_SIZE   64

// one transition per band, plus a leading/trailing "black" to blank above/below
#define PLASMA_BUFFER_LEN  ((PLASMA_LINES + 2) * 4 + 2)
#define PLASMA_FIRST_COLOUR 7    // first band colour slot (after the leading black transition)

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
#define FIRE_BANDS         (FIRE_LINES / FIRE_BAND_HEIGHT)
#define FIRE_BUFFER_LEN    (FIRE_BANDS * FIRE_BAND_BYTES + 2)

static byte copperImage[PLASMA_BUFFER_LEN]; // cloud layout is the larger of the two
static byte plasmaPalette[PLASMA_PAL_SIZE];

// precomputed (sin(i * 2pi/256) + 1) * 15.5, range 0..31 (was built at boot)
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

// fire variant: same band pipeline, different per-line colour source
static byte firePalette[PLASMA_PAL_SIZE];
static byte fireBuf[FIRE_BANDS];

#define FIRE_SEED_ROWS 2   // bottom bands reseeded hot each frame (~4px base at 2px/band)

static byte lerpChannel(byte from, byte to, byte t, byte tmax) {
    return (byte)((int)from + (((int)to - (int)from) * (int)t) / (int)tmax);
}

// interpolate two RRRGGGBB colours per channel
static byte lerpColour(byte from, byte to, byte t, byte tmax) {
    byte r = lerpChannel((from >> 5) & 7, (to >> 5) & 7, t, tmax);
    byte g = lerpChannel((from >> 2) & 7, (to >> 2) & 7, t, tmax);
    byte b = lerpChannel(from & 3, to & 3, t, tmax);
    return RGB332(r, g, b);
}

// Build the 64-entry cloud palette by interpolating low -> mid across the lower
// half and mid -> high across the upper half. Anchors are 8-bit RRRGGGBB; pass
// different triples to tint the cloud per bonus.
static void buildPlasmaPalette(byte low, byte mid, byte high) {
    byte half = PLASMA_PAL_SIZE / 2;
    for (byte i = 0; i < half; ++i)
        plasmaPalette[i] = lerpColour(low, mid, i, half - 1);
    for (byte i = half; i < PLASMA_PAL_SIZE; ++i)
        plasmaPalette[i] = lerpColour(mid, high, i - half, PLASMA_PAL_SIZE - half - 1);
}

static void emitTransition(byte **pp, byte hpos, word waitLine) {
    byte *p = *pp;
    p[0] = 0x80 | (hpos << 1) | ((waitLine >> 8) & 1);
    p[1] = waitLine & 0xFF;
    p[2] = 0x4A;
    p[3] = 0; // colour, filled per frame
    *pp = p + 4;
}

static void buildPlasmaSkeleton(void) {
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
}

// stream the whole program into copper memory (write index 0, copper running)
static void uploadCopperImage(word len) {
    copperAddress(0);
    z80_outp(0x243b, REG_COPPER_DATA);
    dmaMemoryToPort(copperImage, 0x253b, len);
}

static void copperPlasmaUpdate(void) {
    plasmaTimeA += 1;
    plasmaTimeB += 3;

    // plasma() inlined: the two sine indices are gy*GY_A+timeA and gy*GY_B-timeB.
    // gy increments by 1 each band, so strength-reduce the multiplies to running
    // byte accumulators (they wrap mod 256 exactly as (byte)(gy*k) did). This also
    // drops the per-band call + ix-frame overhead that dominated this loop.
    byte ia = plasmaTimeA;          // gy*GY_A + timeA, gy = 0
    byte ib = (byte)(-plasmaTimeB); // gy*GY_B - timeB, gy = 0

    byte *c = copperImage + PLASMA_FIRST_COLOUR; // skip the leading black; each transition is 4 bytes
    for (word i = 0; i < PLASMA_LINES; ++i) {
        byte v = sineTab[ia] + sineTab[ib];
        *c = plasmaPalette[v];
        c += 4;
        ia += GY_A;
        ib += GY_B;
    }
    uploadCopperImage(PLASMA_BUFFER_LEN);
}

// ---------------------------------------------------------------------------
// Fire variant - same full-height band pipeline, driven by a 1D fire sim.
// Heat is seeded at the bottom (high line index) each frame and propagates
// upward; the result reads as flames rising up the screen.
// ---------------------------------------------------------------------------

static void buildFirePalette(void) {
    // Black -> red -> orange -> yellow -> white (RRRGGGBB). Tunable.
    for (byte i = 0; i < PLASMA_PAL_SIZE; ++i) {
        byte r = (i < 24) ? (byte)((i * 7) / 24) : 7;        // red ramps in first, then holds
        byte g = (i < 16) ? 0 : (byte)(((i - 16) * 7) / 47); // green builds -> yellow
        byte b = (i < 48) ? 0 : (byte)(((i - 48) * 3) / 15); // blue only at the hot tip -> white
        firePalette[i] = (r << 5) | (g << 2) | b;
    }
}

// Heat is stored in the full 0..255 range and mapped to the 64-entry palette via
// (heat >> 2). This decouples the per-row cooling amount from the palette
// resolution, so gentle cooling can span the whole screen and flames can reach
// the top (heat 0..255 / ~0.5 cooling per row covers far more than 64 rows).
static void fireStep(void) {
    // reseed the bottom rows hot, with a wide range (128..255) so flame heights vary:
    // the hottest seeds climb to the top, weaker ones fade around mid-screen
    for (byte k = 0; k < FIRE_SEED_ROWS; ++k) {
        fireBuf[FIRE_BANDS - 1 - k] = (byte)(128 + (random16() & 127));
    }
    // propagate upward: each band cools from the band below it (in-place; we read the
    // band below before it is overwritten this pass, so heat shifts up one band/frame).
    // The cool amount only needs 2 random bits (cool by 2 with ~3/4 probability), so
    // draw one random16 and spend it 2 bits at a time - 8 bands per call instead of one.
    word rnd = 0;
    byte rndBits = 0;
    for (word i = 0; i < FIRE_BANDS - 1; ++i) {
        if (rndBits == 0) { rnd = random16(); rndBits = 8; }
        byte cool = (byte)((rnd & 3) ? 2 : 0); // ~1.75/band: doubled vs 1px so the fade spans the same height
        rnd >>= 2;
        --rndBits;

        byte below = fireBuf[i + 1];
        fireBuf[i] = (below > cool) ? (byte)(below - cool) : 0;
    }
}

// Fire skeleton: one band every FIRE_BAND_HEIGHT scanlines that points the palette
// index at the artwork's border slot and sets its colour (filled per frame). The value
// persists for the band's height, so each WAIT + two MOVEs covers multiple lines.
static void buildFireSkeleton(void) {
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
}

static void copperFireUpdate(void) {
    fireStep();

    byte *c = copperImage + FIRE_FIRST_COLOUR;
    for (word i = 0; i < FIRE_BANDS; ++i) {
        *c = firePalette[fireBuf[i] >> 2]; // heat 0..255 -> palette 0..63
        c += FIRE_BAND_BYTES;
    }
    uploadCopperImage(FIRE_BUFFER_LEN);
}

// ---------------------------------------------------------------------------
// Background effect controller. Owns the copper: one effect active at a time,
// and each activation rebuilds the copper program it needs (cloud/fire stream a
// band program via DMA; the flash uses its own stripe skeleton).
// ---------------------------------------------------------------------------

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
    buildLegacySkeleton();

    for(word y = 0; y < STRIPECOUNT; ++y) {
        word address = 3 + (y << 3);
        copperAddress(address);
        ZXN_NEXTREGA(REG_COPPER_DATA, FLASH_BG);
        copperAddress(address+4);
        ZXN_NEXTREGA(REG_COPPER_DATA, FLASH_BG);
    }

    // start copper from index 0, loop at vblank
    ZXN_NEXTREGA(REG_COPPER_CONTROL_H, 0xC0); // https://wiki.specnext.dev/Copper_Control_High_Byte
    ZXN_NEXTREG(REG_COPPER_CONTROL_L, 0);

    flashCyclePos = 7;
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
