#include "resources.h"

void playSample(struct ResourceInfo *restrict info, byte speed, byte loop) __z88dk_callee {
  ZXN_WRITE_MMU1(info->page);
  ZXN_WRITE_MMU2((info->page)+1);
  playWithDma((word)info->resource, info->length, speed, loop);
}

static const struct ResourceInfo zapEffect = R_zzzap_pcm;
void effectZap(void) __z88dk_fastcall {
  playSample(&zapEffect, 0x74, 0);
}

static const struct ResourceInfo sirenEffect = R_siren_pcm;
void effectSiren(void) __z88dk_fastcall {
  playSample(&sirenEffect, 0x74, 0);
}

static const struct ResourceInfo stingEffect = R_sting_pcm;
void effectSting(void) __z88dk_fastcall {
  playSample(&stingEffect, 0x3A, 0);
}

static const struct ResourceInfo menuLoopEffect = R_menu_pcm;
void effectMenuLoop(void) __z88dk_fastcall {
  playSample(&menuLoopEffect, 109, 1);

  for(byte chip=0; chip != 3; ++chip) {
    ayChipSelect(chip);
    aySetEnvelope(14, 0xD000 - (chip * 0x1000));
    for(byte i=0; i != 3; ++i) {
      aySetPitch(i, 19420 + ((chip * 3) + i) * 10);
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
