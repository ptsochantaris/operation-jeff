#include "resources.h"

void gameOverEffect(void) {
  ayChipSelect(0);

  aySetMixer(0, 1, 1);
  aySetEnvelope(0, 0x8000);
  aySetNoise(31);
  aySetPitch(0, 0x500);  
  aySetAmplitude(0, 0x1F);

  aySetMixer(2, 1, 1);
  aySetPitch(2, 0x500);  
  aySetAmplitude(2, 0x1F);
}

static const LevelInfo gameOverInfo = { { 0,0 }, { 0,0 }, 0, 0, 0, SCREEN_ARRAY(gameOverScreen), EmptyResource };
void loadGameOverScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&gameOverInfo);
  fadePaletteUp(&gameOverInfo.paletteAsset, 512, 1);
}

void gameOverLoop(void) __z88dk_fastcall {
  resetBonuses();
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  setHudBackground(0);
  mouseReset();
  status(NULL);

  gameOverEffect();

  loadGameOverScreen();
  applyHudPalette();

  word center = 160;
  word top = 110;
  word x = center - ((4*9) >> 1);
  printNoBackground("GAME OVER", x, top, HUD_ORANGE);

  top += 20;

  if(currentStats.hiScore == currentStats.score, currentStats.score) {
    x = center - ((4*15) >> 1);
    printNoBackground("NEW HIGH SCORE!", x, top, HUD_ORANGE);
    newHighScore();

  } else {
    x = center - ((4*5) >> 1);
    printNoBackground("SCORE", x, top, HUD_ORANGE);
  }

  top += 10;

  x = center - ((4*7) >> 1);
  sprintf(textBuf, "%07lu", currentStats.score);
  printNoBackground(textBuf, x, top, HUD_ORANGE);

  while(1) {
    intrinsic_halt();
    updateMouse();
    if(!mouseState.handled) {
      return;
    }
  }
}
