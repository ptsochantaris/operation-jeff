#include "resources.h"

void gameOverEffect(void) __z88dk_fastcall {
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

static const LevelInfo gameOverHighscoreInfo = FAKE_LEVEL(gameOverHighscoreScreen);
static const LevelInfo gameOverInfo = FAKE_LEVEL(gameOverScreen);
void loadGameOverScreen(byte highScore) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(highScore ? &gameOverHighscoreInfo : &gameOverInfo);
  fadePaletteUp(highScore ? &gameOverHighscoreInfo.paletteAsset : &gameOverInfo.paletteAsset, 512, 1);
}

void gameOverLoop(void) __z88dk_fastcall {
  currentStats.score = 123123; // TODO remove!

  resetBonuses();
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  setHudBackground(0);
  mouseReset();
  status(NULL);

  gameOverEffect();

  byte isHighScore = (currentStats.hiScore == currentStats.score) && currentStats.score;
  loadGameOverScreen(isHighScore);
  applyHudPalette();

  word center = 160;
  word x = center - ((4*9) >> 1);

  word top;
  if(isHighScore) {
    top = 60;
    printNoBackground("GAME OVER", x, top, HUD_ORANGE);
    top += 20;
    x = center - ((4*15) >> 1);
    printNoBackground("NEW HIGH SCORE!", x, top, HUD_ORANGE);
    newHighScore();

  } else {
    top = 110;
    printNoBackground("GAME OVER", x, top, HUD_ORANGE);
    top += 20;
    x = center - ((4*5) >> 1);
    printNoBackground("SCORE", x, top, HUD_ORANGE);
  }

  top += 10;

  x = center - ((4*7) >> 1);
  sprintf(textBuf, "%07lu", currentStats.score);
  printNoBackground(textBuf, x, top, HUD_ORANGE);

  top += 40;
  x = center - ((4*28) >> 1);
  printNoBackground("ENTER YOUR NAME:", x, top, HUD_ORANGE);
  x += (4*18);
  print("          ", x, top, HUD_BLACK, HUD_ORANGE);

  while(1) {
    intrinsic_halt();
    updateMouse();
    if(!mouseState.handled) {
      return;
    }
  }
}
