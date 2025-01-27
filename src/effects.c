#include "effects.h"
#include "resources.h"
#include "dma.h"

void effectMenuDroneStart(void) __z88dk_fastcall {
  for(byte ayChip=0;ayChip<2;++ayChip) {
    ayChipSelect(ayChip);
    for(byte channel=0; channel<3; ++channel) {
      aySetMixer(channel, 1, 0);
      aySetAmplitude(channel, 0x10);
    }
  }

  ayChipSelect(0);

  word pitch = 1672;
  aySetPitch(0, pitch);
  pitch += 160;
  aySetPitch(0, pitch);
  pitch += 160;
  aySetPitch(2, pitch);

  aySetEnvelope(14, 0x4FFF);

  ZXN_WRITE_MMU2(148);
  ZXN_WRITE_MMU3(149);
  playWithDma(0x4000, 16000, 0x80, 1);
}

void effectMenuDroneEnd(void) __z88dk_fastcall {
  stopDma();
  
  ZXN_WRITE_MMU2(10);
  ZXN_WRITE_MMU3(11);

  for(byte ayChip=0; ayChip<3; ++ayChip) {
    ayChipSelect(ayChip);
    for(byte channel=0; channel<3; ++channel) {
      aySetMixer(channel, 0, 0);
      aySetAmplitude(channel, 0x0);
    }
  }
}

void effectFire(void) __z88dk_fastcall {
  ayChipSelect(0);
  aySetEnvelope(0, 1000);
  aySetMixer(1, 1, 0);
  ayPlayNote(1, C2);
  aySetAmplitude(1, 0x10);
}

void effectLand(void) __z88dk_fastcall {
  ayChipSelect(0);
  aySetEnvelope(4, 2000);

  aySetMixer(0, 1, 0);
  ayPlayNote(0, C3);
  aySetAmplitude(0, 0x10);

  aySetMixer(2, 1, 0);
  ayPlayNote(2, C3);
  aySetAmplitude(2, 0x10);
}

void effectExplosion(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 3000);
  aySetNoise(10000);

  aySetMixer(1, 0, 1);
  aySetAmplitude(1, 0x10);
}

void effectDamage(void) __z88dk_fastcall {
  ayChipSelect(1);
  aySetEnvelope(0, 20000);
  aySetNoise(2000);

  aySetMixer(0, 0, 1);
  aySetAmplitude(0, 0x10);

  aySetMixer(2, 0, 1);
  aySetAmplitude(2, 0x10);
}

void effectBonus(void) __z88dk_fastcall {
  ayChipSelect(2);
  aySetEnvelope(0, 20000);
  aySetNoise(1000);
  ayPlayNote(1, C1);
  aySetMixer(1, 1, 1);
  aySetAmplitude(1, 0x10);
}
