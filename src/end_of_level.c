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
  status("CLEAR");

  stopDma();
  dmaResetStatus(); // so we can track playback below
  effectSting();

  ayStopAllSound();
  jeffFlashAll();
  bombsFlashAll();

  fadePaletteDownSlow(1, 512);
  resetAllBombs();
  jeffKillAll(1);
  menuMode();

  dmaWaitForEnd(); // waiting here for sample end
  bombsRestoreFromFlash();
  loadScreen(&levelCompleteInfo);
  endOfLeveDrone();
  status(NULL);

  fadePaletteUp(&levelCompleteInfo.paletteAsset, 512, 1);
  applyHudPalette();

  word top = 54;
  word x = 127;

  sprintf(textBuf, " ZONE %03d: CLEAR", level);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  top += 16;
  sprintf(textBuf, "     TIME: %lu SEC", currentStats.frames / 50);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  top += 16;
  long totalShots = currentStats.shotsHit + currentStats.shotsMiss;
  sprintf(textBuf, "    SHOTS: %lu", totalShots);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  top += 8;
  sprintf(textBuf, "     HITS: %lu", currentStats.shotsHit);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  top += 8;
  sprintf(textBuf, "   MISSES: %lu", currentStats.shotsMiss);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  if(currentStats.shotsMiss) {
    top += 8;
    float ratio = ((currentStats.shotsHit * 100) / totalShots);
    int roundedRatio = (int)ratio;
    sprintf(textBuf, " ACCURACY: %02d%%", roundedRatio);
    printNoBackground(textBuf, x, top, HUD_WHITE);
  }

  top += 16;
  sprintf(textBuf, "  BONUSES: %lu", currentStats.bonusesLanded);
  printNoBackground(textBuf, x, top, HUD_WHITE);
  top += 8;

  sprintf(textBuf, "COLLECTED: %lu", currentStats.bonusesHit);
  printNoBackground(textBuf, x, top, HUD_WHITE);

  while(1) {
    intrinsic_halt();
    updateMouse();

    if(!mouseState.handled) {
      return;
    }
  }
}
