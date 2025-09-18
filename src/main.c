#include "base.h"

int main(void) {
  ZXN_NEXTREG(REG_TURBO_MODE, 3);
  ZXN_NEXTREGA(REG_PERIPHERAL_3, RP3_DISABLE_CONTENTION | RP3_ENABLE_TURBOSOUND | RP3_ENABLE_SPECDRUM);

  haltCopper();
  esxDosRomSetup();
  setupScreen();
  initTilemap();
  loadSprites();
  initStats();
  mouseInit();

  intrinsic_ei();

  while(1) {
    byte startLevel = menuLoop();

    if(gameLoop(startLevel)) {
      break;
    }

    gameOverLoop();
  }

  ZXN_NEXTREG(REG_RESET, RR_SOFT_RESET);
  return 0;
}
