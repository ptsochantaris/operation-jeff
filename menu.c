#include "resources.h"

void soundSetup(void) {
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

  aySetEnvelope(14, 0x1FFF);
}

void soundStop(void) {
  for(byte ayChip=0; ayChip<3; ++ayChip) {
    ayChipSelect(ayChip);
    for(byte channel=0; channel<3; ++channel) {
      aySetMixer(channel, 0, 0);
      aySetAmplitude(channel, 0x0);
    }
  }
}

static byte menuInfoMode = 0;

byte inputDelay = 0;

void setupTitle(void) __z88dk_fastcall {
  loadTitleScreen();
  setupTitleLeds();
  menuInfoMode = 0;
}

void menuLoop(void) __z88dk_fastcall {
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  setupTitle();
  mouseReset();

  byte loopCount = 0;

  soundSetup();

  while(1) {
    intrinsic_halt();
    
    if(!mouseClicked.handled) {
      mouseClicked.handled = 1;

      if(menuInfoMode) {
        setupTitle();

      } else {
        soundStop();
        return;
      }
    }

    updateMouse();

    if(!menuInfoMode && ++loopCount == 6) {
      cycleGrayPalette();
      loopCount = 0;
    }

    if(inputDelay) --inputDelay;

    byte pressed = z80_inp(0xdffe);
    if((inputDelay == 0) && (pressed & 4) == 0) { // i
      inputDelay = SMALL_INPUT_DELAY;
      if(menuInfoMode) {
        setupTitle();
      } else {
        ulaAttributeClear();
        loadInfoScreen();
        menuInfoMode = 1;
      }
    }
  }
}
