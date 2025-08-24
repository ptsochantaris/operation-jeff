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

static const struct LevelInfo endGameInfo = FAKE_LEVEL(endGame);

#define center 160

void waitForClick(void) __z88dk_fastcall {
  while(1) {
    intrinsic_halt();
    updateMouse();

    if(!mouseState.handled) {
      return;
    }
  }
}

void displayStats(word top, word x, byte level, word color, byte twoColumns) {
  word originalTop = top;

  applyHudPalette();

  sprintf(textBuf, " ZONE %03d: CLEAR", level);
  printNoBackground(textBuf, x, top, color);

  top += 16;
  sprintf(textBuf, "     TIME: %lu SEC", currentStats.frames / 50);
  printNoBackground(textBuf, x, top, color);

  if(twoColumns) {
    top = originalTop;
    x += 178;
  } else {
    top += 16;
  }

  long totalShots = 123; //currentStats.shotsHit + currentStats.shotsMiss;
  sprintf(textBuf, "    SHOTS: %lu", totalShots);
  printNoBackground(textBuf, x, top, color);

  top += 8;
  sprintf(textBuf, "     HITS: %lu", currentStats.shotsHit);
  printNoBackground(textBuf, x, top, color);

  top += 8;
  sprintf(textBuf, "   MISSES: %lu", currentStats.shotsMiss);
  printNoBackground(textBuf, x, top, color);

  if(currentStats.shotsMiss) {
    top += 8;
    float ratio = ((currentStats.shotsHit * 100) / totalShots);
    int roundedRatio = (int)ratio;
    sprintf(textBuf, " ACCURACY: %02d%%", roundedRatio);
    printNoBackground(textBuf, x, top, color);
  }

  top += 16;
  sprintf(textBuf, "  BONUSES: %lu", currentStats.bonusesLanded);
  printNoBackground(textBuf, x, top, color);
  top += 8;

  sprintf(textBuf, "COLLECTED: %lu", currentStats.bonusesHit);
  printNoBackground(textBuf, x, top, color);
}

void endOfLevelSequence(const struct LevelInfo levelInfo) {
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
  persistHighestLevel();

  dmaWaitForEnd(); // waiting here for sample end
  bombsRestoreFromFlash();

  loadScreen(&levelInfo);
  endOfLeveDrone();
  status(NULL);

  fadePaletteUp(&levelInfo.paletteAsset, 512, 1);
}

void endOfLeveLoop(byte level) __z88dk_fastcall {
  endOfLevelSequence(levelCompleteInfo);
  displayStats(54, 127, level, HUD_WHITE, 0);
  waitForClick();
}

void endOfGameLoop(byte level) __z88dk_fastcall {
  endOfLevelSequence(endGameInfo);
  displayStats(28, 42, level, HUD_BLACK, 1);
  waitForClick();
}
