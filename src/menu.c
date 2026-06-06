#include "base.h"

static byte menuInfoMode = 0;

byte inputDelay = 0;

static byte shouldFadeTitle = 0;
static const struct ScreenInfo titleInfo = SCREEN_ARRAY(title);
static void loadTitleScreen(void) __z88dk_fastcall {
  if(shouldFadeTitle) {
    fadePaletteDown(1, 1, 0);
  } else {
    zeroPalette(1);
  }
  loadScreen(titleInfo.screens);
  if(shouldFadeTitle) {
    fadePaletteUp(&titleInfo.palette, 1);
  } else {
    uploadPalette(&titleInfo.palette, 256, 1);
    shouldFadeTitle = 1;
  }
}

static const struct ScreenInfo infoInfo = SCREEN_ARRAY(info);
static void loadInfoScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 1, 0);
  loadScreen(infoInfo.screens);
  fadePaletteUp(&infoInfo.palette, 1);
}

static void setupTitle(void) __z88dk_fastcall {
  loadTitleScreen();
  setupTitleLeds();
  menuInfoMode = 0;

  word x = 160 - ((4*18) >> 1);
  sprintf(textBuf, "HIGH SCORE %07lu", highScores[0].score);
  print(textBuf, x, 12, 4);

  if(currentStats.highestLevel > 0) {
    x = 160 - ((4*33) >> 1);
    sprintf(textBuf, "PRESS C TO CONTINUE FROM LEVEL %02d", currentStats.highestLevel + 1);
    print(textBuf, x, 241, 18);
  }

  ayStopAllSound();
  effectMenuLoop();
}

static void setupInfo(void) __z88dk_fastcall {
  stopDma();
  ayStopAllSound();
  ulaAttributeClear();
  loadInfoScreen();
  menuInfoMode = 1;
}

void menuMode(void) __z88dk_fastcall {
  copperShutdown();
  setSpriteMenuClipping();
  setMenuMouse();
  mouseReset();
  setupLayers(0); // SLU
  ulaAttributeClear();

  // testing
  // copperForeground(0x07, 0x05, 0x00, 1);
}

byte menuLoop(void) __z88dk_fastcall {
  stopDma();
  menuMode();
  status(NULL);
  setupTitle();

  byte loopCount = 0;

  while(1) {
    updateMouse();

    // testing
    // copperCycle();

    if(!mouseState.handled) {
      mouseState.handled = 1;

      if(menuInfoMode) {
        setupTitle();

      } else {
        stopDma();
        return 0;
      }
    }

    if(!menuInfoMode) {
      if(++loopCount == 6) {
        cycleGrayPalette();
        loopCount = 0;
      }
    }

    if(inputDelay) {
      --inputDelay;
    } else {
      byte pressed = readKeyboardLetter();
      if(pressed == 'I') {
        inputDelay = SMALL_INPUT_DELAY;
        if(menuInfoMode) {
          setupTitle();
        } else {
          setupInfo();
        }
      } else if(pressed == 'C') {
        inputDelay = SMALL_INPUT_DELAY;
        if(menuInfoMode) {
          setupTitle();
        } else {
          stopDma();
          return currentStats.highestLevel;
        }
      }
    }
  }
}
