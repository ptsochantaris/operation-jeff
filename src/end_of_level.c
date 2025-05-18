#include "resources.h"

void endOfLeveEffect(void) __z88dk_fastcall {
  ayChipSelect(0);
  aySetEnvelope(10, 0x1FFF);
  aySetMixer(1, 1, 0);
  ayPlayNote(1, E0);
  aySetAmplitude(1, 0x10);

  ayChipSelect(1);
  aySetEnvelope(14, 0x0FFF);
  aySetMixer(1, 1, 0);
  ayPlayNote(1, A0);
  aySetAmplitude(1, 0x10);

  ayChipSelect(2);
  aySetEnvelope(10, 0x0FFF);
  aySetMixer(1, 1, 0);
  ayPlayNote(1, B0);
  aySetAmplitude(1, 0x10);
}

static const struct LevelInfo levelCompleteInfo = FAKE_LEVEL(levelComplete);
void loadEndOfLevelScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&levelCompleteInfo);
  fadePaletteUp(&levelCompleteInfo.paletteAsset, 512, 1);
}

#define center 160

void endOfLeveLoop(byte level) __z88dk_fastcall {
  menuMode();
  status(NULL);
  endOfLeveEffect();
  loadEndOfLevelScreen();
  applyHudPalette();

  word x = center - ((4*14) >> 1);
  word top = 53;

  sprintf(textBuf, "ZONE %03d CLEARED", level);
  printNoBackground(textBuf, x, top, HUD_WHITE);
  top += 20;

  byte keyDown = 0;

  while(1) {
    intrinsic_halt();
    updateMouse();

    if(!mouseState.handled) {
      return;
    }
  }
}
