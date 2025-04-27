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

static const LevelInfo gameOverInfo = FAKE_LEVEL(gameOverScreen);
void loadGameOverScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&gameOverInfo);
  fadePaletteUp(&gameOverInfo.paletteAsset, 512, 1);
}

void printHiScoreName(char *hiScoreBuf, word x, word top) {
  print(hiScoreBuf, x, top, HUD_BLACK, HUD_ORANGE);
}

void gameOverLoop(void) __z88dk_fastcall {
  currentStats.hiScore = 123123; // TODO remove!
  currentStats.score = 123123; // TODO remove!

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

  byte isHighScore = (currentStats.hiScore == currentStats.score) && currentStats.score;

  word center = 160;
  word x = center - ((4*9) >> 1);

  word top;
  if(isHighScore) {
    top = 90;
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

  byte hiScoreBufPos = 0;
  byte hiScoreBuf[11] = "          ";
  byte keyPressed = 0;

  if(isHighScore) {
    top += 26;
    x = center - ((4*28) >> 1);
    printNoBackground("ENTER YOUR NAME:", x, top, HUD_ORANGE);
    x += (4*17);
    layer2roundedBox(x - 2, top - 2, 4*10 + 2, 8, HUD_ORANGE);
    layer2fill(x - 1, top - 1, 4*10 + 1, 7, HUD_ORANGE);
  }

  while(1) {
    intrinsic_halt();
    updateMouse();
    if(!mouseState.handled) {
      return;
    }

    if(isHighScore) {
      byte letter = readKeyboardLetter();
      if(letter < 8) {
        keyPressed = 0;
        continue;
      }
      
      if(keyPressed) {
        continue;
      }
      keyPressed = 1;

      if(letter == 8) {
        if(hiScoreBufPos > 0) {
          hiScoreBuf[--hiScoreBufPos] = ' ';
        }

      } else if(letter == 13) {
        // TODO submit

      } else {
        if(hiScoreBufPos > 9) {
          hiScoreBufPos = 9;
        }
        hiScoreBuf[hiScoreBufPos++] = letter;
      }

      printHiScoreName(hiScoreBuf, x, top);
    }
  }
}
