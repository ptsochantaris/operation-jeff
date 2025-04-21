#include "resources.h"

static byte menuInfoMode = 0;

byte inputDelay = 0;

static byte shouldFadeTitle = 0;
static const LevelInfo titleInfo = { { 0,0 }, { 0,0 }, 0, 0, 0, SCREEN_ARRAY(title), EmptyResource };
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

static const LevelInfo infoInfo = { { 0,0 }, { 0,0 }, 0, 0, 0, SCREEN_ARRAY(info), EmptyResource };
void loadInfoScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&infoInfo);
  fadePaletteUp(&infoInfo.paletteAsset, 512, 1);
}

void setupTitle(void) __z88dk_fastcall {
  loadTitleScreen();
  setupTitleLeds();
  menuInfoMode = 0;
  if(currentStats.hiScore > 0) {
    word x = 160 - ((4*18) >> 1);
    sprintf(textBuf, "HIGH SCORE %07lu", currentStats.hiScore);
    printNoBackground(textBuf, x, 10, 4);
  }
  effectMenuLoop();
  playTitleSong();
}

void setupInfo(void) __z88dk_fastcall {
  stopDma();
  ayStopAllSound();
  ulaAttributeClear();
  loadInfoScreen();
  menuInfoMode = 1;
}

void menuLoop(void) __z88dk_fastcall {
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  setupTitle();
  mouseReset();

  byte loopCount = 0;

  while(1) {
    intrinsic_halt();
    
    if(!mouseState.handled) {
      mouseState.handled = 1;

      if(menuInfoMode) {
        setupTitle();

      } else {
        stopDma();
        ayStopAllSound();
        return;
      }
    }

    updateMouse();

    if(!menuInfoMode) {
      updateTitleSong();
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
    }
  }
}
