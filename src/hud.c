#include "resources.h"

#define RATE_X 8
#define ENERGY_X 34
#define HEALTH_X 232
#define RATE_Y 34
#define SCORE_X 134
#define HISCORE_X 186

extern const byte *bFont;

void print(const byte *restrict text, word x, word y, byte textColor, byte bgColor) {
  byte C = *text;
  do {
    const byte *base = bFont + (6 * (C - 32));
    for(byte v=0; v!=5; ++v, ++base, ++y) {
      byte slice = *base;
      for(byte h=5; h != 8; ++h) {
        byte color = (slice & (1 << h)) ? textColor : bgColor;
        layer2Plot(x + (7 - h), y, color);
      }
    }
    C = *(++text);
    x += 4;
    y -= 5;
  } while(C != 0);
}

void printNoBackground(const byte *restrict text, word x, word y, byte textColor) {
  byte C = *text;
  do {
    const byte *base = bFont + (6 * (C - 32));
    for(byte v=0; v!=5; ++v, ++base, ++y) {
      byte slice = *base;
      for(byte h=5; h != 8; ++h) {
        if(slice & (1 << h)) {
          layer2Plot(x + (7 - h), y, textColor);
        }
      }
    }
    C = *(++text);
    x += 4;
    y -= 5;
  } while(C != 0);
}

void printSidewaysNoBackground(const byte *text, word x, word y, byte textColor) {
  selectLayer2Page(x >> 6);
  byte C = *text;
  do {
    const byte *base = bFont + (6 * (C - 32));
    for(byte v=0; v!=5; ++v, ++base, ++x) {
      byte slice = *base;
      for(byte h=5; h != 8; ++h) {
        if(slice & (1 << h)) {
          byte *pos = (byte *)((x % 64) * 256 + (y - (7 - h)));
          *pos = textColor;
        }
      }
    }
    C = *(++text);
    y -= 4;
    x -= 5;
  } while(C != 0);
}

byte textBuf[10];

void hudEnergyUpdated(void) __z88dk_fastcall {
  byte width = currentStats.energy >> 2;
  layer2fill(ENERGY_X + 2, 10, width, 2, HUD_GREEN);
  layer2fill(ENERGY_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
}

#define RATE_HEIGHT 200
void hudRateUpdated(void) __z88dk_fastcall {
  byte height = ((currentStats.fireRate - FIRE_RATE_MIN) * RATE_HEIGHT) / (FIRE_RATE_MAX - FIRE_RATE_MIN);
  word invHeight = RATE_HEIGHT - height;
  layer2fill(RATE_X + 2, RATE_Y + 2, 2, height, HUD_YELLOW);
  layer2fill(RATE_X + 2, RATE_Y + 2 + height, 2, invHeight, HUD_BLUE);
}

void hudHealthUpdated(void) __z88dk_fastcall {
  byte width = currentStats.health >> 2;
  layer2fill(HEALTH_X + 2, 10, width, 2, HUD_RED);
  layer2fill(HEALTH_X + 2 + width, 10, 64 - width, 2, HUD_BLACK);
}

void hudScoreUpdated(void) __z88dk_fastcall {
  sprintf(textBuf, "%07lu", currentStats.score);
  print(textBuf, SCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);
  sprintf(textBuf, "%07lu", currentStats.hiScore);
  print(textBuf, HISCORE_X - 4, 8, HUD_WHITE, HUD_BLACK);
}

#define LEVEL_PROGRESS_WIDTH 7

void hudKillsUpdated(void) __z88dk_fastcall {
  word level = (currentStats.killsInLevel * LEVEL_PROGRESS_WIDTH) / currentStats.maxKillsInLevel;
  if(level > LEVEL_PROGRESS_WIDTH) {
    return;
  }
  
  byte dividerY = 14-(level << 1) + 3;
  layer2circleFill(7, 1, 3, HUD_FILL_DARK, HUD_FILL_LIGHT, dividerY);
  
  int res = currentStats.maxKillsInLevel - currentStats.killsInLevel;
  if(res >= 0) {
    sprintf(textBuf, "%03d", res);
    printNoBackground(textBuf, 3, 8, HUD_WHITE);
  }
}

void setHudBackground(int color) __z88dk_fastcall {
  selectPalette(1);
  ZXN_NEXTREG(0x40, HUD_BLACK); // start palette index
  ZXN_NEXTREGA(0x44, color & 0xFF);
  ZXN_NEXTREGA(0x44, (color >> 8) & 0x01);
}

static const byte hudPalette[] = {
  COLOR9(0, 0, 0),
  COLOR9(7, 4, 0),
  COLOR9(7, 7, 0),
  COLOR9(7, 0, 0),
  COLOR9(0, 7, 0),
  COLOR9(0, 0, 7),
  COLOR9(7, 7, 7)
};

void applyHudPalette(void) __z88dk_fastcall {
  selectPalette(1); // L2 first palette
  ZXN_NEXTREG(0x40, HUD_BLACK); // start palette index
  writeNextReg(0x44, hudPalette, 14);
}

void initHud(byte level) __z88dk_fastcall {
  applyHudPalette();

  const LevelInfo info = levelInfo[level];
  writeColourToIndex(info.jeffDark, HUD_FILL_DARK);
  writeColourToIndex(info.jeffBright, HUD_FILL_LIGHT);

  layer2DmaFill(0, 0, 16, 256, HUD_BLACK);
  layer2DmaFill(16, 0, 320, 15, HUD_BLACK);

  printNoBackground("CHARGE", ENERGY_X + 22, 1, HUD_WHITE);
  printNoBackground("SCORE", SCORE_X, 1, HUD_WHITE);
  printNoBackground("HIGH", HISCORE_X + 2, 1, HUD_WHITE);
  printNoBackground("HEALTH", HEALTH_X + 22, 1, HUD_WHITE);

  printSidewaysNoBackground("CHARGING", 1, 100, HUD_WHITE);
  printSidewaysNoBackground("FIRE RATE", 1, 200, HUD_WHITE);

  layer2box(RATE_X, RATE_Y, 5, 203, HUD_WHITE);
  layer2box(ENERGY_X, 8, 66, 5, HUD_WHITE);
  layer2box(HEALTH_X, 8, 66, 5, HUD_WHITE);

  layer2circleFill(8, 0, 2, HUD_WHITE, HUD_WHITE, 0);

  hudScoreUpdated();
  hudHealthUpdated();
  hudRateUpdated();
  hudEnergyUpdated();
  hudKillsUpdated();
}
