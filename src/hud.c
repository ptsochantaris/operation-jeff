#include "base.h"

#define RATE_X 8
#define ENERGY_X 34
#define HEALTH_X 232
#define RATE_Y 34
#define SCORE_X 134
#define HISCORE_X 186

static struct stats displayedStats;

static void hudEnergyDraw(void) __z88dk_fastcall {
  byte width = displayedStats.energy >> 2;
  layer2fill(ENERGY_X + 2, 10, width, 2, HUD_GREEN);
  layer2fill(ENERGY_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
}

#define RATE_HEIGHT 200
static void hudRateDraw(void) __z88dk_fastcall {
  byte height = ((displayedStats.fireRate - FIRE_RATE_MIN) * RATE_HEIGHT) / (FIRE_RATE_MAX - FIRE_RATE_MIN);
  word invHeight = RATE_HEIGHT - height;
  layer2fill(RATE_X + 2, RATE_Y + 2, 2, height, HUD_YELLOW);
  layer2fill(RATE_X + 2, RATE_Y + 2 + height, 2, invHeight, HUD_BLUE);
}

static void hudHealthDraw(void) __z88dk_fastcall {
  byte width = displayedStats.health >> 2;
  layer2fill(HEALTH_X + 2, 10, width, 2, HUD_RED);
  layer2fill(HEALTH_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
}

static void hudScoreDraw(void) __z88dk_fastcall {
  sprintf(textBuf, "%07lu", displayedStats.score);
  printWithBackground(textBuf, SCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);
  sprintf(textBuf, "%07lu", highScores[0].score);
  printWithBackground(textBuf, HISCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);
}

static void hudBorderDraw(void) __z88dk_fastcall {
  if(displayedStats.invunerableCount) {
    copperForeground(5, 1);
  } else if(displayedStats.damageFlash) {
    copperForeground(0x40, 2);
  } else if(displayedStats.umbrellaCountdown) {
    copperForeground(0x41, 1);
  } else {
    copperShutdown();
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

static const byte hudPalette[] = {
  COLOR9(0, 0, 0), // HUD_BLACK
  COLOR9(7, 4, 0),
  COLOR9(7, 7, 0),
  COLOR9(7, 0, 0),
  COLOR9(0, 7, 0),
  COLOR9(0, 0, 7),
  COLOR9(7, 7, 7)
};

extern byte paletteBuffer[];

void stashHudPalette(byte level) __z88dk_fastcall {
  byte *data = paletteBuffer+(HUD_BLACK*2);
  for(byte index=0; index !=14; ++index, ++data) {
    *data = hudPalette[index];
  }

  const struct LevelInfo info = levelInfo[level];
  data = paletteBuffer + (2*HUD_FILL_TEXT);
  *data++ = info.fontDark[0];
  *data = info.fontDark[1];

  data = paletteBuffer + (2*HUD_FILL_DARK);
  *data++ = info.jeffDark[0];
  *data = info.jeffDark[1];

  data = paletteBuffer + (2*HUD_FILL_LIGHT);
  *data++ = info.jeffBright[0];
  *data = info.jeffBright[1];
}

void applyHudPalette(void) __z88dk_fastcall {
  selectPalette(1); // L2 first palette
  ZXN_NEXTREG(REG_PALETTE_INDEX, HUD_BLACK);
  writeNextReg(REG_PALETTE_VALUE_16, hudPalette, 14);
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

  byte needsBorderDraw = 0;
  if(currentStats.damageFlash) {
    if(!displayedStats.damageFlash) {
      displayedStats.damageFlash = 1;
      needsBorderDraw = 1;
    }
  } else if(displayedStats.damageFlash) {
    displayedStats.damageFlash = 0;
    needsBorderDraw = 1;
  }

  if(currentStats.invunerableCount) {
    if(!displayedStats.invunerableCount) {
      displayedStats.invunerableCount = 1;
      needsBorderDraw = 1;
    }
  } else if(displayedStats.invunerableCount) {
    displayedStats.invunerableCount = 0;
    needsBorderDraw = 1;
  }
  
  if(currentStats.umbrellaCountdown) {
    if(!displayedStats.umbrellaCountdown) {
      displayedStats.umbrellaCountdown = 1;
      needsBorderDraw = 1;
    }
  } else if(displayedStats.umbrellaCountdown) {
    displayedStats.umbrellaCountdown = 0;
    needsBorderDraw = 1;
  }

  if(needsBorderDraw) {
    hudBorderDraw();
  }
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
  hudScoreDraw();
  hudHealthDraw();
  hudRateDraw();
  hudEnergyDraw();
  hudKillsDraw();
  hudBorderDraw();

  stashHudPalette(level);
}
