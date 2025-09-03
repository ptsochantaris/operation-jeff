#include "resources.h"

static byte menuInfoMode = 0;

byte inputDelay = 0;

static byte shouldFadeTitle = 0;
static const struct LevelInfo titleInfo = FAKE_LEVEL(title);
void loadTitleScreen(void) __z88dk_fastcall {
  if(shouldFadeTitle) {
    fadePaletteDown(1, 512);
  } else {
    zeroPalette(1, 512);
  }
  loadScreen(&titleInfo);
  if(shouldFadeTitle) {
    fadePaletteUp(&titleInfo.paletteAsset, 512, 1);
  } else {
    uploadPalette(&titleInfo.paletteAsset, 512, 1);
    shouldFadeTitle = 1;
  }
}

static const struct LevelInfo infoInfo = FAKE_LEVEL(info);
void loadInfoScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&infoInfo);
  fadePaletteUp(&infoInfo.paletteAsset, 512, 1);
}

void setupTitle(void) __z88dk_fastcall {
  loadTitleScreen();
  setupTitleLeds();
  menuInfoMode = 0;

  word x = 160 - ((4*18) >> 1);
  sprintf(textBuf, "HIGH SCORE %07lu", highScores[0].score);
  printNoBackground(textBuf, x, 12, 4);

  /* Benchmarking text printing */
  /*
  sprintf(textBuf, "THIS IS A LONG BIT OF TEXT, THAT *SHOULD* TAKE UP MOST OF THE SCREEN WIDTH!");
  for(byte c=0;c!=10;c++) {
    for(int f=0;f<250;f+=8) {
      printNoBackground(textBuf, 0, f, c);
      // print(textBuf, 0, f, c, 1);
    }
  }
  */

  if(currentStats.highestLevel > 0) {
    x = 160 - ((4*33) >> 1);
    sprintf(textBuf, "PRESS C TO CONTINUE FROM LEVEL %02d", currentStats.highestLevel + 1);
    printNoBackground(textBuf, x, 241, 18);
  }

  ayStopAllSound();
  effectMenuLoop();
}

void setupInfo(void) __z88dk_fastcall {
  stopDma();
  ayStopAllSound();
  ulaAttributeClear();
  loadInfoScreen();
  menuInfoMode = 1;
}

void menuMode(void) __z88dk_fastcall {
  setSpriteMenuClipping();
  setMenuMouse();
  mouseReset();
  setupLayers(0); // SLU
  setFallbackColour(0);
  ulaAttributeClear();
}

byte menuLoop(void) __z88dk_fastcall {
  stopDma();
  menuMode();
  status(NULL);
  setupTitle();

  byte loopCount = 0;

  while(1) {
    intrinsic_halt();
    
    if(!mouseState.handled) {
      mouseState.handled = 1;

      if(menuInfoMode) {
        setupTitle();

      } else {
        stopDma();
        return 0;
      }
    }

    updateMouse();

    if(!menuInfoMode) {
      if(++loopCount == 6) {
        cycleGrayPalette();
        loopCount = 0;
      }
    }

    if(inputDelay) {
      --inputDelay;
    } else {
      byte pressed = z80_inp(0xdffe);
      if((pressed & 4) == 0) { // "i"
        inputDelay = SMALL_INPUT_DELAY;
        if(menuInfoMode) {
          setupTitle();
        } else {
          setupInfo();
        }
      }

      pressed = z80_inp(0xfefe);
      if((pressed & 8) == 0) { // "c"
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
