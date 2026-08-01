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

  // The title has to be decompressed at boot anyway, so do it into the prefetch
  // pages: the cold-boot cost is one extra DMA blit, and in exchange the copy
  // stays tagged for the rest of the session, making every info->title toggle
  // (and every return from game over) a blit instead of a decompress.
  prefetchTitleScreen();

  while(1) {
    byte startLevel = menuLoop();
    gameLoop(startLevel);
    gameOverLoop();
  }
}
