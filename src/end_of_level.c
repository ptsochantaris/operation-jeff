#include "base.h"
#include "music.h"

// Written as E0, A0 and B0 originally, but those table entries (10619, 7955 and
// 7086) all overflow the 12 bit period register and reached the AY as the masked
// values below - which is the chord that has always played. Spelled out as raw
// periods so it stops reading as an E minor triad that it never was.
static const word endOfLevelPitch[] = {2427, 3859, 2990}; // 45.07, 28.34, 36.58 Hz
static const byte endOfLevelEnvelopeType[] = {10, 14, 10};
static const word endOfLevelEnvelopeLength[] = {0x1FFF, 0x0FFF, 0x0FFF};

static void endOfLeveDrone(void) __z88dk_fastcall {
  for(byte chip=0; chip != 3; ++chip) {
    ayChipSelect(chip);
    aySetEnvelope(endOfLevelEnvelopeType[chip], endOfLevelEnvelopeLength[chip]);
    aySetPitch(1, endOfLevelPitch[chip]);
    aySetAmplitude(1, 0x10);
    aySetMixer(1, 1, 0);
  }
}

#define center 160

static void waitForClick(void) __z88dk_fastcall {
  while(1) {
    waitOne();

    if(!mouseState.handled) {
      mouseState.handled = 1;
      return;
    }
  }
}

static void displayStats(word top, word x, byte oldLevel, word color, byte twoColumns) __z88dk_callee {
  word originalTop = top;

  applyHudPalette();

  sprintf(textBuf, " ZONE %02d: CLEAR", oldLevel + 1);
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

  long totalShots = currentStats.shotsHit + currentStats.shotsMiss;
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

static void endOfLevelSequence(const struct LevelInfo *levelInfo) __z88dk_fastcall {
  stopAudioTimer();
  effectSting();
  status("CLEAR");
  
  ayStopAllSound();
  jeffFlashAll();
  bombsFlashAll();

  wait(20);
  copperEffectOff();
  fadePaletteDown(1, 4, 1);

  resetAllBombs();
  jeffKillAll(1);

  persistHighestLevel();
  menuMode();

  while(sampleActive) {
    waitOne(); // let the sting finish before reusing the sample banks
  }
  bombsRestoreFromFlash();

  loadScreen(&(levelInfo->endOfLevel.screens));
  endOfLeveDrone();
  status(NULL);

  fadePaletteUp(&(levelInfo->endOfLevel.palette), 1);
}

void endOfLeveLoop(byte oldLevel) __z88dk_fastcall {
  const struct LevelInfo info = levelInfo[oldLevel];
  endOfLevelSequence(&info);
  if(oldLevel >= LEVEL_COUNT - 1) {
    displayStats(28, 42, oldLevel, HUD_BLACK, 1);
  } else {
    displayStats(54, 127, oldLevel, HUD_WHITE, 0);
  }

  // decompress the next level's screen while the player reads the stats, so
  // the upcoming loadScreen becomes a DMA blit instead of a ~5-12 frame stall.
  // safe here: the sting sample has finished (waited on above) and only the AY
  // drone is playing, so MMU1/MMU2 are ours. currentStats.level was already
  // advanced by statsProgressLevel() before endOfLeveLoop was called.
  prefetchScreen(levelInfo[currentStats.level].level.screens);

  waitForClick();
}
