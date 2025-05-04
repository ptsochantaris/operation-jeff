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

static const struct LevelInfo gameOverInfo = FAKE_LEVEL(gameOverScreen);
void loadGameOverScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 512);
  loadScreen(&gameOverInfo);
  fadePaletteUp(&gameOverInfo.paletteAsset, 512, 1);
}

void displayHighScoreTable(word x, word top, byte recordCount) {
  for(byte i = 0; i < recordCount; ++i) {
    top += 10;
    printNoBackground(highScores[i].name, x, top, HUD_ORANGE);    
    sprintf(textBuf, "%07lu", highScores[i].score);
    printNoBackground(textBuf, x + 50, top, HUD_ORANGE);    
  }
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

  byte isHighScore = (currentStats.hiScore == currentStats.score) && currentStats.score;

  #define center 160
  word x = center - ((4*9) >> 1);
  byte hiScoreBufPos = 0;
  byte hiScoreBuf[11] = "          ";
  word top = 53;

  printNoBackground("GAME OVER", x, top, HUD_ORANGE);
  top += 20;

  if(isHighScore) {
    top += 5;
    x = center - ((4*15) >> 1);
    printNoBackground("NEW HIGH SCORE!", x, top, HUD_WHITE);
    top += 10;
    printNoBackground("ENTER YOUR NAME", x, top, HUD_WHITE);
    top += 25;

    x = center - ((4*20) >> 1);
    layer2fill(x - 1, top - 1, 4*10 + 1, 7, HUD_BLACK);
    layer2roundedBox(x - 2, top - 2, 4*10 + 2, 8, HUD_WHITE);

    sprintf(textBuf, "%07lu", currentStats.score);
    printNoBackground(textBuf, x + 50, top, HUD_WHITE);

    displayHighScoreTable(x, top, HIGHSCORE_SLOTS - 1);

  } else {
    x = center - ((4*5) >> 1);
    printNoBackground("SCORE", x, top, HUD_ORANGE);
    top += 10;

    x = center - ((4*7) >> 1);
    sprintf(textBuf, "%07lu", currentStats.score);
    printNoBackground(textBuf, x, top, HUD_ORANGE);  
    top += 16;

    x = center - ((4*20) >> 1);
    displayHighScoreTable(x, top, HIGHSCORE_SLOTS);
  }

  byte keyDown = 0;

  while(1) {
    intrinsic_halt();
    updateMouse();

    if(isHighScore) {
      byte letter = readKeyboardLetter();
      if(letter < 8) {
        keyDown = 0;
        continue;
      }
      
      if(keyDown) {
        continue;
      }
      keyDown = 1;

      if(letter == 8) {
        if(hiScoreBufPos > 0) {
          hiScoreBuf[--hiScoreBufPos] = ' ';
        }

      } else if(letter == 13) {
        newHighScore(hiScoreBuf);
        return;

      } else {
        if(hiScoreBufPos > 9) {
          hiScoreBufPos = 9;
        }
        hiScoreBuf[hiScoreBufPos++] = letter;
      }

      print(hiScoreBuf, x, top, HUD_WHITE, HUD_BLACK);

    } else {
      if(!mouseState.handled) {
        return;
      }  
    }
  }
}
