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

#define MENU_DRONE_HIGH_1 1116 // G3      (true 98.0 Hz)
#define MENU_DRONE_HIGH_2 1674 // C3 -2c  (true 65.3 Hz)
#define MENU_DRONE_PEAK 13
#define MENU_DRONE_CYCLE 2400 // frames: lowest common multiple of the three periods

static const word menuDronePitch[] = {
  3344, 3360, 1676,                // chip 0: C2, C2 -8c, C3 -4c   (true 32.7, 32.6, 65.3 Hz)
  1672, MENU_DRONE_HIGH_1, 3352,   // chip 1: C3, high, C2 -4c     (true 65.4, -, 32.6 Hz)
  1680, MENU_DRONE_HIGH_2, 1684,   // chip 2: C3 -8c, high, C3 -12c
};

static const word menuDroneRamp[] = { 400, 300, 200 };

// Amplitude steps taken off each voice, in menuDronePitch order - the two high
// voices sit about 6dB under the rest of the swell.
static const byte menuDroneCut[] = {
  0, 0, 0,
  0, 2, 0,
  0, 2, 0,
};
static word menuDroneFrame;

void effectMenuLoop(void) __z88dk_fastcall {
  playSample(&menuLoopEffect, SAMPLE_TC_8K, 1);

  const word *pitch = menuDronePitch;
  for(byte chip=0; chip != 3; ++chip) {
    ayChipSelect(chip);
    for(byte i=0; i != 3; ++i) {
      aySetPitch(i, *pitch++);
      aySetAmplitude(i, 0);
      aySetMixer(i, 1, 0);
    }
  }
  menuDroneFrame = 0;
}

// Call once per frame while the menu loop is playing.
void effectMenuDroneUpdate(void) __z88dk_fastcall {
  const byte *cut = menuDroneCut;
  for(byte chip=0; chip != 3; ++chip) {
    word ramp = menuDroneRamp[chip];
    word t = menuDroneFrame % (ramp << 1);
    if(t > ramp) {
      t = (ramp << 1) - t;
    }
    byte level = (t * MENU_DRONE_PEAK) / ramp;
    ayChipSelect(chip);
    for(byte i=0; i != 3; ++i) {
      byte c = *cut++;
      aySetAmplitude(i, level > c ? level - c : 0);
    }
  }
  if(++menuDroneFrame == MENU_DRONE_CYCLE) {
    menuDroneFrame = 0;
  }
}

static const word gameOverDronePitch[] = {
  3977, 3995, 4019,  // chip 1: A1 cluster, 18 cents wide (27.50, 27.38, 27.21 Hz)
  1327, 1332, 1337,  // chip 2: E3 cluster, 13 cents wide (82.42, 82.11, 81.81 Hz)
};

static const byte gameOverDroneAmplitude[] = { 12, 10, 11, 9, 7, 8 };

#define RUMBLE_FIRST_GAP 200   // frames: the first rumble comes 4-6 seconds in
#define RUMBLE_FIRST_RANGE 100
#define RUMBLE_GAP_MIN 100     // frames of silence between rumbles: 2-6 seconds
#define RUMBLE_GAP_RANGE 200
#define RUMBLE_PERIOD_MIN 2432 // growl period range: 2432-3455, 45.0-31.7Hz
#define RUMBLE_PEAK_MIN 11     // peak amplitude is 11-14, just over the drone
#define RUMBLE_RISE_RATE 15    // frames per amplitude step: a 1.5-2.25 second rise
#define RUMBLE_FALL_RATE 25    // ...and a 2.5-3.75 second fade

enum { RUMBLE_WAITING, RUMBLE_RISING, RUMBLE_FALLING };
static byte gameOverRumblePhase;
static word gameOverRumbleWait;
static byte gameOverRumbleChannel;
static byte gameOverRumblePeak;
static byte gameOverRumbleLevel;
static byte gameOverRumbleCount;

void effectGameOverDrone(void) __z88dk_fastcall {
  // Channels 0 and 2 of chip 0 belong to the crash in gameOverEffect(). Channel
  // 1 is free, and a fixed amplitude ignores that effect's decay envelope.
  ayChipSelect(0);
  aySetPitch(1, 1989); // A2, 54.99Hz
  aySetAmplitude(1, 8);
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

  gameOverRumblePhase = RUMBLE_WAITING;
  gameOverRumbleWait = RUMBLE_FIRST_GAP + (random16() % RUMBLE_FIRST_RANGE);
}

// Call once per frame while the game over screen is up.
void effectGameOverDroneUpdate(void) __z88dk_fastcall {
  if(gameOverRumblePhase != RUMBLE_WAITING) {
    ayChipSelect(0);
    aySetPitch(gameOverRumbleChannel, RUMBLE_PERIOD_MIN + (random16() & 1023));
  }

  switch(gameOverRumblePhase) {
    case RUMBLE_WAITING:
      if(--gameOverRumbleWait) {
        return;
      }
      gameOverRumbleChannel = (random16() & 1) << 1;
      gameOverRumblePeak = RUMBLE_PEAK_MIN + (random16() & 3);
      gameOverRumbleLevel = 0;
      gameOverRumbleCount = RUMBLE_RISE_RATE;
      gameOverRumblePhase = RUMBLE_RISING;
      ayChipSelect(0);
      aySetNoise(28 + (random16() & 3)); // 28-31, the lowest noise the AY makes
      aySetAmplitude(gameOverRumbleChannel, 0);
      aySetMixer(gameOverRumbleChannel, 1, 1);
      return;

    case RUMBLE_RISING:
      if(--gameOverRumbleCount) {
        return;
      }
      gameOverRumbleCount = RUMBLE_RISE_RATE;
      ayChipSelect(0);
      aySetAmplitude(gameOverRumbleChannel, ++gameOverRumbleLevel);
      if(gameOverRumbleLevel == gameOverRumblePeak) {
        gameOverRumbleCount = RUMBLE_FALL_RATE;
        gameOverRumblePhase = RUMBLE_FALLING;
      }
      return;

    default: // RUMBLE_FALLING
      if(--gameOverRumbleCount) {
        return;
      }
      gameOverRumbleCount = RUMBLE_FALL_RATE;
      ayChipSelect(0);
      aySetAmplitude(gameOverRumbleChannel, --gameOverRumbleLevel);
      if(!gameOverRumbleLevel) {
        aySetMixer(gameOverRumbleChannel, 0, 0);
        gameOverRumbleWait = RUMBLE_GAP_MIN + (random16() % RUMBLE_GAP_RANGE);
        gameOverRumblePhase = RUMBLE_WAITING;
      }
      return;
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
