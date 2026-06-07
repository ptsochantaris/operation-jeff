#include "base.h"

int main(void) {
  ZXN_NEXTREG(REG_TURBO_MODE, 3);
  ZXN_NEXTREGA(REG_PERIPHERAL_3, RP3_DISABLE_CONTENTION | RP3_ENABLE_TURBOSOUND | RP3_ENABLE_SPECDRUM);

  esxDosRomSetup();
  copperInit();
  setupScreen();
  initTilemap();
  loadSprites();
  initStats();

  setupInterrupts(); // switch from legacy IM1 to hardware IM2 (ULA frame + CTC audio)

  while(1) {
    byte startLevel = menuLoop();
    gameLoop(startLevel);
    gameOverLoop();
  }
}
