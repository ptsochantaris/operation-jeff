#include "resources.h"

static byte menuInfoMode = 0;

byte inputDelay = 0;

void setupTitle(void) __z88dk_fastcall {
  loadTitleScreen();
  setupTitleLeds();
  menuInfoMode = 0;
}

void menuLoop(void) __z88dk_fastcall {
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  setupTitle();
  mouseReset();
  effectMenuDroneStart();

  byte loopCount = 0;

  while(1) {
    intrinsic_halt();
    
    if(!mouseState.handled) {
      mouseState.handled = 1;

      if(menuInfoMode) {
        setupTitle();

      } else {
        effectMenuDroneEnd();
        return;
      }
    }

    updateMouse();

    if(!menuInfoMode && ++loopCount == 6) {
      cycleGrayPalette();
      loopCount = 0;
    }

    if(inputDelay) --inputDelay;

    byte pressed = z80_inp(0xdffe);
    if((inputDelay == 0) && (pressed & 4) == 0) { // i
      inputDelay = SMALL_INPUT_DELAY;
      if(menuInfoMode) {
        setupTitle();
      } else {
        ulaAttributeClear();
        loadInfoScreen();
        menuInfoMode = 1;
      }
    }
  }
}
