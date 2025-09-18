#include "base.h"

static void gameOverEffect(void) __z88dk_fastcall {
  ayChipSelect(0);

  aySetEnvelope(0, 0x8000);
  aySetNoise(31);

  aySetPitch(0, 0x500);  
  aySetPitch(2, 0x500);  

  aySetAmplitude(0, 0x10);
  aySetAmplitude(2, 0x10);

  aySetMixer(0, 1, 1);
  aySetMixer(2, 1, 1);
}

static const struct LevelInfo gameOverInfo = FAKE_LEVEL(gameOver);
static void loadGameOverScreen(void) __z88dk_fastcall {
  fadePaletteDown(1, 1, 0);
  loadScreen(&gameOverInfo);
  fadePaletteUp(&gameOverInfo.paletteAsset, 256, 1);
}

#define center 160

void gameOverLoop(void) __z88dk_fastcall {
  resetBonuses();
  menuMode();
  status(NULL);
  stopDma();
  ayStopAllSound();
  gameOverEffect();
  persistHighestLevel();
  loadGameOverScreen();
  applyHudPalette();

  byte highScoreSlot = HIGHSCORE_SLOTS;
  if(currentStats.score) {
    for(int i = HIGHSCORE_SLOTS - 1; i >= 0; --i) {
      if(highScores[i].score <= currentStats.score) {
        highScoreSlot = i;
      }
    }
  }

  word x = center - ((4*9) >> 1);
  byte hiScoreBufPos = 0;
  byte hiScoreBuf[11] = "          ";
  word top = 53;

  printNoBackground("GAME OVER", x, top, HUD_ORANGE);
  top += 20;

  if(highScoreSlot == HIGHSCORE_SLOTS) {
    x = center - ((4*5) >> 1);
    printNoBackground("SCORE", x, top, HUD_ORANGE);
    top += 10;

    x = center - ((4*7) >> 1);
    sprintf(textBuf, "%07lu", currentStats.score);
    printNoBackground(textBuf, x, top, HUD_ORANGE);  

  } else {
    top += 3;
    x = center - ((4*15) >> 1);
    printNoBackground("NEW HIGH SCORE!", x, top, HUD_WHITE);
    top += 10;
    printNoBackground("ENTER YOUR NAME", x, top, HUD_WHITE);
  }

  top += 14;
  x = center - ((4*19) >> 1);
  word entryY = displayHighScoreTable(x, top, highScoreSlot);

  byte keyDown = 0;

  while(1) {
    intrinsic_halt();
    updateMouse();

    if(entryY) {
      byte letter = readKeyboardLetter();
      if(letter < 8) {
        keyDown = 0;
        continue;
      }

      if(keyDown) {
        continue;
      }
      keyDown = 1;

      if(letter == '0' && keyboardShiftPressed) {
        if(hiScoreBufPos > 0) {
          hiScoreBuf[--hiScoreBufPos] = ' ';
        }

      } else if(letter == 13) {
        newHighScore(hiScoreBuf, highScoreSlot);
        return;

      } else {
        if(hiScoreBufPos > 9) {
          hiScoreBufPos = 9;
        }
        hiScoreBuf[hiScoreBufPos++] = letter;
      }

      print(hiScoreBuf, x, entryY, HUD_WHITE, HUD_BLACK);

    } else if(!mouseState.handled) {
      return;
    }
  }
}
