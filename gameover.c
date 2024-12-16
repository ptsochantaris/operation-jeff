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

void gameOverLoop(void) __z88dk_fastcall {
  resetBonuses();
  setSpriteMenuClipping();
  setMenuMouse();
  setupLayers(0); // SLU
  layer2Clear(HUD_ORANGE);
  setHudBackground(0);
  mouseReset();
  status(NULL);

  gameOverEffect();

  layer2DmaFill(60, 60, 200, 136, HUD_BLACK);

  word center = 160;
  word top = 110;
  word x = center - ((4*9) >> 1);
  print("GAME OVER", x, top, HUD_ORANGE, HUD_BLACK);

  top += 20;

  if(currentStats.hiScore == currentStats.score, currentStats.score) {
    x = center - ((4*15) >> 1);
    print("NEW HIGH SCORE!", x, top, HUD_ORANGE, HUD_BLACK);
  } else {
    x = center - ((4*5) >> 1);
    print("SCORE", x, top, HUD_ORANGE, HUD_BLACK);
  }

  top += 10;

  x = center - ((4*7) >> 1);
  sprintf(textBuf, "%07lu", currentStats.score);
  print(textBuf, x, top, HUD_ORANGE, HUD_BLACK);

  while(1) {
    intrinsic_halt();
    updateMouse();
    if(!mouseClicked.handled) {
      return;
    }
  }
}
