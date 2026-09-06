#include "base.h"

#define RATE_X 8
#define ENERGY_X 34
#define HEALTH_X 232
#define RATE_Y 34
#define SCORE_X 134
#define HISCORE_X 186

static struct stats displayedStats;

#define RATE_HEIGHT 200

// The bars only ever move by a unit or two per update, so the incremental draws
// repaint just the band that changed instead of the whole 64-column / 200-row bar.
// initHud does the full repaint and re-seeds these after the screen is rebuilt.
static byte drawnEnergyWidth;
static byte drawnHealthWidth;
static byte drawnRateHeight;

static void hudEnergyDrawFull(void) __z88dk_fastcall {
  byte width = displayedStats.energy >> 2;
  layer2fill(ENERGY_X + 2, 10, width, 2, HUD_GREEN);
  layer2fill(ENERGY_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
  drawnEnergyWidth = width;
}

static void hudEnergyDraw(void) __z88dk_fastcall {
  byte width = displayedStats.energy >> 2;
  if(width > drawnEnergyWidth) {
    layer2fill(ENERGY_X + 2 + drawnEnergyWidth, 10, width - drawnEnergyWidth, 2, HUD_GREEN);
  } else if(width < drawnEnergyWidth) {
    layer2fill(ENERGY_X + 2 + width, 10, drawnEnergyWidth - width, 2, HUD_BLACK);
  }
  drawnEnergyWidth = width;
}

static byte hudRateHeight(void) __z88dk_fastcall {
  return ((displayedStats.fireRate - FIRE_RATE_MIN) * RATE_HEIGHT) / (FIRE_RATE_MAX - FIRE_RATE_MIN);
}

static void hudRateDrawFull(void) __z88dk_fastcall {
  byte height = hudRateHeight();
  word invHeight = RATE_HEIGHT - height;
  layer2fill(RATE_X + 2, RATE_Y + 2, 2, height, HUD_YELLOW);
  layer2fill(RATE_X + 2, RATE_Y + 2 + height, 2, invHeight, HUD_BLUE);
  drawnRateHeight = height;
}

static void hudRateDraw(void) __z88dk_fastcall {
  byte height = hudRateHeight();
  if(height > drawnRateHeight) {
    layer2fill(RATE_X + 2, RATE_Y + 2 + drawnRateHeight, 2, height - drawnRateHeight, HUD_YELLOW);
  } else if(height < drawnRateHeight) {
    layer2fill(RATE_X + 2, RATE_Y + 2 + height, 2, drawnRateHeight - height, HUD_BLUE);
  }
  drawnRateHeight = height;
}

static void hudHealthDrawFull(void) __z88dk_fastcall {
  byte width = displayedStats.health >> 2;
  layer2fill(HEALTH_X + 2, 10, width, 2, HUD_RED);
  layer2fill(HEALTH_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
  drawnHealthWidth = width;
}

static void hudHealthDraw(void) __z88dk_fastcall {
  byte width = displayedStats.health >> 2;
  if(width > drawnHealthWidth) {
    layer2fill(HEALTH_X + 2 + drawnHealthWidth, 10, width - drawnHealthWidth, 2, HUD_RED);
  } else if(width < drawnHealthWidth) {
    layer2fill(HEALTH_X + 2 + width, 10, drawnHealthWidth - width, 2, HUD_BLACK);
  }
  drawnHealthWidth = width;
}

static unsigned long drawnHighScore;

// The stored table is only rewritten at game over, but the player can overtake
// it mid-level, so the HUD shows whichever of the two is currently higher.
static unsigned long hudHighScore(void) __z88dk_fastcall {
  unsigned long stored = (unsigned long)highScores[0].score;
  return (displayedStats.score > stored) ? displayedStats.score : stored;
}

static void hudHighScoreDraw(void) __z88dk_fastcall {
  drawnHighScore = hudHighScore();
  sprintf(textBuf, "%07lu", drawnHighScore);
  printWithBackground(textBuf, HISCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);
}

static void hudScoreDraw(void) __z88dk_fastcall {
  sprintf(textBuf, "%07lu", displayedStats.score);
  printWithBackground(textBuf, SCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);

  // Repaint the high score only when it actually moves. It is unchanged for most
  // of a game, and redrawing it regardless was over half the cost of an update.
  if(hudHighScore() != drawnHighScore) {
    hudHighScoreDraw();
  }
}

static void hudBorderDraw(void) __z88dk_fastcall {
  if(currentStats.invunerableCount) {
    copperEffectCloud(SHIELD_CLOUD);
  } else if(currentStats.damageFlash) {
    copperEffectFlash();
  } else if(currentStats.umbrellaCountdown) {
    copperEffectCloud(UMBRELLA_CLOUD);
  } else if(currentStats.slowMo) {
    copperEffectCloud(SLOW_CLOUD);
  } else if(currentStats.supergun || currentStats.extraRangeBombs) {
    copperEffectCloud(GUNBOOST_CLOUD);
  } else {
    // Close rather than stop: a cloud collapses back into the middle of the screen
    // over the next few updates instead of vanishing between two frames.
    copperEffectClose();
  }
}

#define LEVEL_PROGRESS_WIDTH 7
#define LEVEL_PROGRESS_HEIGHT 9

static void hudKillsDraw(void) __z88dk_fastcall {
  word level = (displayedStats.killsInLevel * LEVEL_PROGRESS_HEIGHT) / displayedStats.maxKillsInLevel;
  if(level > LEVEL_PROGRESS_HEIGHT) {
    return;
  }
  
  byte dividerY = 18-(level << 1);
  layer2circleFill(7, 3, 3, HUD_FILL_DARK, HUD_FILL_LIGHT, dividerY);
  
  int res = displayedStats.maxKillsInLevel - displayedStats.killsInLevel;
  if(res >= 0) {
    sprintf(textBuf, "%03d", res);
    print(textBuf, 5, 8, HUD_FILL_TEXT);
  }
}

static byte hudPalette[] = {
  COLOR9(0, 0, 0), // HUD_MASK
  COLOR9(0, 0, 0), // HUD_FILL_TEXT
  COLOR9(0, 0, 0), // HUD_FILL_LIGHT
  COLOR9(0, 0, 0), // HUD_FILL_DARK

  COLOR9(0, 0, 0), // HUD_BLACK
  COLOR9(7, 4, 0),
  COLOR9(7, 7, 0),
  COLOR9(7, 0, 0),
  COLOR9(0, 7, 0),
  COLOR9(0, 0, 7),
  COLOR9(7, 7, 7)
};

extern byte paletteBuffer[];

static void stashHudPalette(byte level) __z88dk_fastcall {
  const struct LevelInfo info = levelInfo[level];

  byte *data = hudPalette+2; // HUD_MASK as-is, skip 2 bytes
  
  *data++ = info.fontDark[0];
  *data++ = info.fontDark[1];

  *data++ = info.jeffBright[0];
  *data++ = info.jeffBright[1];

  *data++ = info.jeffDark[0];
  *data = info.jeffDark[1];

  const byte *buf = paletteBuffer + (HUD_BASE * 2);
  memcpy(buf, hudPalette, HUD_COLOUR_BYTES);
}

void applyHudPalette(void) __z88dk_fastcall {
  selectPalette(1); // L2 first palette
  ZXN_NEXTREG(REG_PALETTE_INDEX, HUD_BASE);
  writeNextReg(REG_PALETTE_VALUE_16, hudPalette, HUD_COLOUR_BYTES);
}

void updateStatsIfNeeded(void) __z88dk_fastcall {
  if(displayedStats.score != currentStats.score) {
    displayedStats.score = currentStats.score;
    hudScoreDraw();
  }
  if(displayedStats.health != currentStats.health) {
    displayedStats.health = currentStats.health;
    hudHealthDraw();
  }
  if(displayedStats.fireRate != currentStats.fireRate) {
    displayedStats.fireRate = currentStats.fireRate;
    hudRateDraw();
  }
  if(displayedStats.energy != currentStats.energy) {
    displayedStats.energy = currentStats.energy;
    hudEnergyDraw();
  }
  if(displayedStats.killsInLevel != currentStats.killsInLevel) {
    displayedStats.killsInLevel = currentStats.killsInLevel;
    hudKillsDraw();
  }

  // damage flash: shake the screen while active, reset the scroll once when it ends
  if(currentStats.damageFlash) {
    displayedStats.damageFlash = 1;
    word offset = currentStats.damageFlash % 2;
    scrollLayer2(offset, 0);
    scrollTilemap(offset, 0);

  } else if(displayedStats.damageFlash) {
    displayedStats.damageFlash = 0;
    scrollLayer2(0, 0);
    scrollTilemap(0, 0);
  }

  // The border effect reads live state and re-evaluates every frame, so it can't
  // get out of sync with the bonuses. The copperEffect* calls dedupe, so this is
  // cheap (no rebuild/upload unless the active effect actually changes).
  hudBorderDraw();
}

void initHud(byte level) __z88dk_fastcall {
  print("CHARGE", ENERGY_X + 22, 1, HUD_WHITE);
  print("SCORE", SCORE_X, 1, HUD_WHITE);
  print("HIGH", HISCORE_X + 2, 1, HUD_WHITE);
  print("HEALTH", HEALTH_X + 22, 1, HUD_WHITE);

  printSideways("CHARGING", 1, 98, HUD_WHITE);
  printSideways("FIRE RATE", 1, 196, HUD_WHITE);

  layer2box(RATE_X, RATE_Y, 5, 203, HUD_WHITE);
  layer2box(ENERGY_X, 8, 66, 5, HUD_WHITE);
  layer2box(HEALTH_X, 8, 66, 5, HUD_WHITE);

  layer2circleFill(8, 2, 2, HUD_WHITE, HUD_WHITE, 0);

  displayedStats = currentStats;
  hudHighScoreDraw();     // unconditional, the screen was just rebuilt
  hudScoreDraw();
  hudHealthDrawFull();
  hudRateDrawFull();
  hudEnergyDrawFull();
  hudKillsDraw();
  hudBorderDraw();

  stashHudPalette(level);
}
