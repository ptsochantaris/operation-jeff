#include "resources.h"

int main(void) {
  ZXN_NEXTREG(REG_TURBO_MODE, 3);
  ZXN_NEXTREGA(REG_PERIPHERAL_3, ZXN_READ_REG(REG_PERIPHERAL_3) | RP3_DISABLE_CONTENTION | RP3_ENABLE_TURBOSOUND | RP3_ENABLE_SPECDRUM);
  ZXN_WRITE_MMU0(28);

  setupScreen();
  loadSprites();
  initTilemap();
  initStats();
  mouseInit();

  intrinsic_ei();

  while(1) {
    menuLoop();

    if(gameLoop()) {
      break;
    }

    gameOverLoop();
  }

  ZXN_NEXTREGA(REG_RESET, RR_SOFT_RESET);
  return 0;
}
