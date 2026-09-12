#include "base.h"

static const struct ResourceInfo zapEffect = R_zzzap_pcm;
void effectZap(void) __z88dk_fastcall {
  playSample(&zapEffect, SAMPLE_TC_8K, 0);
}

static const struct ResourceInfo sirenEffect = R_siren_pcm;
void effectSiren(void) __z88dk_fastcall {
  playSample(&sirenEffect, SAMPLE_TC_8K, 0);
}

static const struct ResourceInfo stingEffect = R_sting_pcm;
void effectSting(void) __z88dk_fastcall {
  playSample(&stingEffect, SAMPLE_TC_16K, 0);
}

static const struct ResourceInfo menuLoopEffect = R_menu_pcm;

// Nine AY voices droning under the looping menu sample.
//
// The loop's tonal centre is C - its strongest partial sits right on the C4
// entry of notePitches (sound.c), whose labels run an octave above true pitch.
//
// The original version stacked all nine voices 10 period units apart around
// 3036, which is a 45 cent cluster (about a quarter tone) centred on a flat D:
// a major second against the loop's C, and wide enough that the 5th and 7th
// harmonics of these square waves beat at 4-7Hz. That rate is heard as
// roughness rather than chorus, which was the dissonance.
//
// These are octaves and fifths of C instead - the small integer ratios square
// waves lock to without beating - with no third at all, so the pad implies
// neither major nor minor and stays out of the loop's way. The stack sits as
// low as the hardware allows: a true octave below this would put the root under
// the AY's 26.7Hz floor (period 4095), so the bottom is doubled at C2 rather
// than transposed, and the top lands on C4, the loop's own root partial.
//
// The fifth only appears from C3 up. Below that the interval falls inside one
// critical band - C2 against G2 is 16Hz apart at 33Hz - and reads as mud rather
// than as a chord, so the bottom octave is left as pure octaves.
//
// Movement comes from detuning each doubled voice, 4-12 cents apart, which is
// 0.08 to 0.47Hz of beating. That stays slow enough that even the 5th harmonic
// beats under 2.5Hz, well clear of the roughness band the original fell into.
//
// The C4 pair that used to cap the stack is gone, putting the ceiling on G3 at
// 98Hz and the freed voices on C2 and C3. For the brighter voicing, restore
// 3352 -> 836 and 1684 -> 838.
static const word menuDronePitch[] = {
  3344, 3360, 1676,  // chip 0: C2, C2 -8c, C3 -4c   (true 32.7, 32.6, 65.3 Hz)
  1672, 1116, 3352,  // chip 1: C3, G3, C2 -4c       (true 65.4, 98.0, 32.6 Hz)
  1680, 1120, 1684,  // chip 2: C3 -8c, G3 -6c, C3 -12c
};

// Type 14 triangle swells with ramps of 8, 6 and 4 seconds, i.e. 16, 12 and 8
// second cycles - whole multiples of the 2.0023s sample loop (16000 bytes at
// 28MHz/16/219). Writing R13 restarts the envelope, so all three set off in
// step with the sample and stay locked to it.
static const word menuDroneEnvelope[] = { 54688, 41016, 27344 };

void effectMenuLoop(void) __z88dk_fastcall {
  playSample(&menuLoopEffect, SAMPLE_TC_8K, 1);

  const word *pitch = menuDronePitch;
  for(byte chip=0; chip != 3; ++chip) {
    ayChipSelect(chip);
    aySetEnvelope(14, menuDroneEnvelope[chip]);
    for(byte i=0; i != 3; ++i) {
      aySetPitch(i, *pitch++);
      aySetAmplitude(i, 0x10);
      aySetMixer(i, 1, 0);
    }
  }
}

void effectFire(void) __z88dk_fastcall {
  ayChipSelect(0);
  aySetEnvelope(0, 1000);
  ayPlayNote(1, C2);
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 0);
}

void effectLand(void) __z88dk_fastcall {
  ayChipSelect(0);
  aySetEnvelope(4, 2000);

  ayPlayNote(0, C3);
  ayPlayNote(2, C3);

  aySetAmplitude(0, 0x10);
  aySetAmplitude(2, 0x10);

  aySetMixer(0, 1, 0);
  aySetMixer(2, 1, 0);
}

void effectExplosion(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 3000);
  aySetNoise(16);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 0, 1);
}

void effectBomb(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 30000);
  aySetNoise(31);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 0, 1);
}

void effectBombShort(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 10000);
  aySetNoise(31);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 0, 1);
}

void effectBombRise(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(8, 500);
  ayPlayNote(1, 8000);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 0);
}

void effectBombLightStart(void) __z88dk_fastcall {
  ayChipSelect(2);
  aySetEnvelope(8, 500);
  aySetNoise(1);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 0, 1);
}

void effectBombLightEnd(void) __z88dk_fastcall {
  ayChipSelect(2);
  aySetEnvelope(0, 5000);
  aySetNoise(1);

  aySetAmplitude(1, 0x10);
  aySetMixer(1, 0, 1);
}

void effectDamage(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 10000);
  aySetNoise(16);

  aySetAmplitude(0, 0x10);
  aySetAmplitude(2, 0x10);

  aySetMixer(0, 0, 1);
  aySetMixer(2, 0, 1);
}

void effectBonus(void) __z88dk_fastcall {
  ayChipSelect(2);
  aySetEnvelope(0, 20000);
  aySetNoise(8);
  
  ayPlayNote(1, C1);
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 1);
}
