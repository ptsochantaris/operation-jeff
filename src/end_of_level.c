#include "base.h"

static void endOfLeveDrone(void) __z88dk_fastcall {
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

static struct LevelInfo levelCompleteInfos[] = {
  FAKE_LEVEL(levelCompleteA),
  FAKE_LEVEL(levelCompleteO),
  FAKE_LEVEL(levelCompleteB),
  FAKE_LEVEL(levelCompleteG),
  FAKE_LEVEL(levelCompleteD),
  FAKE_LEVEL(levelCompleteI),
  FAKE_LEVEL(levelCompleteL),
  FAKE_LEVEL(levelCompleteE),
  FAKE_LEVEL(levelCompleteN),
  FAKE_LEVEL(levelCompleteP),
  FAKE_LEVEL(levelCompleteJ),
  FAKE_LEVEL(levelCompleteQ),
  FAKE_LEVEL(levelCompleteC),
  FAKE_LEVEL(levelCompleteK),
  FAKE_LEVEL(levelCompleteM),
  FAKE_LEVEL(levelCompleteF),
  FAKE_LEVEL(levelCompleteH)
};

#define center 160

static void waitForClick(void) __z88dk_fastcall {
  while(1) {
    updateMouse();

    if(!mouseState.handled) {
      mouseState.handled = 1;
      return;
    }
  }
}

static void displayStats(word top, word x, byte level, word color, byte twoColumns) {
  word originalTop = top;

  applyHudPalette();

  sprintf(textBuf, " ZONE %02d: CLEAR", level);
  print(textBuf, x, top, color);

  top += 16;
  sprintf(textBuf, "     TIME: %lu SEC", currentStats.frames / 50);
  print(textBuf, x, top, color);

  if(twoColumns) {
    top = originalTop;
    x += 178;
  } else {
    top += 16;
  }

  long totalShots = 123; //currentStats.shotsHit + currentStats.shotsMiss;
  sprintf(textBuf, "    SHOTS: %lu", totalShots);
  print(textBuf, x, top, color);

  top += 8;
  sprintf(textBuf, "     HITS: %lu", currentStats.shotsHit);
  print(textBuf, x, top, color);

  top += 8;
  sprintf(textBuf, "   MISSES: %lu", currentStats.shotsMiss);
  print(textBuf, x, top, color);

  if(currentStats.shotsMiss) {
    top += 8;
    float ratio = ((currentStats.shotsHit * 100) / totalShots);
    int roundedRatio = (int)ratio;
    sprintf(textBuf, " ACCURACY: %02d%%", roundedRatio);
    print(textBuf, x, top, color);
  }

  top += 16;
  sprintf(textBuf, "  BONUSES: %lu", currentStats.bonusesLanded);
  print(textBuf, x, top, color);
  top += 8;

  sprintf(textBuf, "COLLECTED: %lu", currentStats.bonusesHit);
  print(textBuf, x, top, color);
}

static void wait(byte time) __z88dk_fastcall {
  for(byte f=0;f!=time;f++) {
    intrinsic_halt();
  }
}

static void endOfLevelSequence(const struct LevelInfo levelInfo) {
  stopDma();
  dmaResetStatus(); // so we can track playback below
  effectSting();
  status("CLEAR");

  ayStopAllSound();
  jeffFlashAll();
  bombsFlashAll();

  wait(20);
  fadePaletteDown(1, 4, 1);

  resetAllBombs();
  jeffKillAll(1);

  persistHighestLevel();
  menuMode();

  dmaWaitForEnd(); // waiting here for sample end
  bombsRestoreFromFlash();

  loadScreen(&levelInfo);
  endOfLeveDrone();
  status(NULL);

  fadePaletteUp(&levelInfo.paletteAsset, 1);
}

void endOfLeveLoop(byte level) __z88dk_fastcall {
  endOfLevelSequence(levelCompleteInfos[level-1]);
  displayStats(54, 127, level, HUD_WHITE, 0);
  waitForClick();
}

void endOfGameLoop(byte level) __z88dk_fastcall {
  endOfLevelSequence(levelCompleteInfos[level-1]);
  displayStats(28, 42, level, HUD_BLACK, 1);
  waitForClick();
}
