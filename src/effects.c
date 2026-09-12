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

static const word menuDronePitch[] = {
  3344, 3360, 1676,  // chip 0: C2, C2 -8c, C3 -4c   (true 32.7, 32.6, 65.3 Hz)
  1672, 1116, 3352,  // chip 1: C3, G3, C2 -4c       (true 65.4, 98.0, 32.6 Hz)
  1680, 1120, 1684,  // chip 2: C3 -8c, G3 -6c, C3 -12c
};

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

static const word gameOverDronePitch[] = {
  3977, 3995, 4019,  // chip 1: A1 cluster, 18 cents wide (27.50, 27.38, 27.21 Hz)
  1327, 1332, 1337,  // chip 2: E3 cluster, 13 cents wide (82.42, 82.11, 81.81 Hz)
};

static const byte gameOverDroneAmplitude[] = { 13, 11, 12, 10, 8, 9 };

void effectGameOverDrone(void) __z88dk_fastcall {
  // Channels 0 and 2 of chip 0 belong to the crash in gameOverEffect(). Channel
  // 1 is free, and a fixed amplitude ignores that effect's decay envelope.
  ayChipSelect(0);
  aySetPitch(1, 1989); // A2, 54.99Hz
  aySetAmplitude(1, 9);
  aySetMixer(1, 1, 0);

  const word *pitch = gameOverDronePitch;
  const byte *amplitude = gameOverDroneAmplitude;
  for(byte chip=1; chip != 3; ++chip) {
    ayChipSelect(chip);
    for(byte i=0; i != 3; ++i) {
      aySetPitch(i, *pitch++);
      aySetAmplitude(i, *amplitude++);
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
  ayPlayNote(1, E5); // was a raw 8000, but the note argument is a byte, so it truncated to index 64 - this note, 329.44Hz

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
  
  aySetPitch(1, 2594); // was C1, whose 6690 overflows the 12 bit period register and reaches the AY as this: 42.16Hz
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 1);
}
