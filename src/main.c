#include "base.h"

int main(void) {
  ZXN_NEXTREG(REG_TURBO_MODE, 3);
  ZXN_NEXTREGA(REG_PERIPHERAL_3, RP3_DISABLE_CONTENTION | RP3_ENABLE_TURBOSOUND | RP3_ENABLE_SPECDRUM);

  copperInit();
  esxDosRomSetup();
  setupScreen();
  initTilemap();
  loadSprites();
  initStats();

  setupInterrupts(); // switch from legacy IM1 to hardware IM2 (ULA only for now)
  intrinsic_ei();

  while(1) {
    byte startLevel = menuLoop();
    gameLoop(startLevel);
    gameOverLoop();
  }
}
