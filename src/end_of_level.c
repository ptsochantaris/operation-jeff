#include "resources.h"

void endOfLeveDrone(void) __z88dk_callee {
  ayChipSelect(0);
  aySetEnvelope(10, 0x1FFF);
  ayPlayNote(1, E0);
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 0);

  ayChipSelect(1);
  aySetEnvelope(14, 0x0FFF);
  ayPlayNote(1, A0);
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 0);

  ayChipSelect(2);
  aySetEnvelope(10, 0x0FFF);
  ayPlayNote(1, B0);
  aySetAmplitude(1, 0x10);
  aySetMixer(1, 1, 0);
}

static const struct LevelInfo levelCompleteInfo = FAKE_LEVEL(levelComplete);

#define center 160

void endOfLeveLoop(byte level) __z88dk_fastcall {
  ayStopAllSound();
  stopDma();
  dmaResetStatus(); // so we can track playback below
  effectSting();

  fadePaletteDownSlow(1, 512);
  menuMode();

  dmaWaitForEnd();

  loadScreen(&levelCompleteInfo);
  fadePaletteUp(&levelCompleteInfo.paletteAsset, 512, 1);
  applyHudPalette();

  word x = center - ((4*14) >> 1);
  word top = 53;

  sprintf(textBuf, "ZONE %03d CLEARED", level);
  printNoBackground(textBuf, x, top, HUD_WHITE);
  top += 20;

  endOfLeveDrone();

  byte keyDown = 0;

  while(1) {
    intrinsic_halt();
    updateMouse();

    if(!mouseState.handled) {
      return;
    }
  }
}
