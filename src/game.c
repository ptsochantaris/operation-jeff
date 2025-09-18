#include "resources.h"

static void nextLevel(byte gameStart) __z88dk_fastcall {
  byte previousLevel = currentStats.level;

  resetBonuses();
  statsProgressLevel();
  stopDma(); // stop any potential sample, as level loading will use the same buffers

  byte newLevel = currentStats.level;
  if(previousLevel == LEVEL_COUNT - 1) {
    endOfGameLoop(LEVEL_COUNT);
  } else if(!gameStart) {
    endOfLeveLoop(newLevel);
  }

  fadePaletteDown(1);

  gameMode();

  const struct LevelInfo info = levelInfo[newLevel];
  loadScreen(&info);
  loadHeightmap(&info);

  statsInitLevel();
  initHud(newLevel);

  effectSiren();

  fadePaletteUp(&(info.paletteAsset), nonHudPaletteColourCount, 1);

  selectPalette(2);
  writeColourToIndex(info.jeffDark, 128);
  writeColourToIndex(info.jeffBright, 224);

  sprintf(textBuf, "ZONE %03d", newLevel + 1);
  status(textBuf);
}

static void gameMode(void) __z88dk_fastcall {
  ayStopAllSound();
  setSpriteGameClipping();
  setGameMouse();
  setupLayers(2); // SUL
  ulaAttributeClear();
  mouseReset();
}

static void pauseKeys(byte key) __z88dk_fastcall {
  if(keyboardSymbolShiftPressed && key >= 48 && key < 58) {
    if(key=='0') {
      key = 8;
    } else {
      key -= 50;
    }
    if(keyboardShiftPressed) {
      key += 10;
      if(key >= LEVEL_COUNT) {
        key = LEVEL_COUNT - 1;
      }
    }
    currentStats.level = key;
    nextLevel(0);
  } else {
    status("GO");
  }
}

byte gameLoop(byte startLevel) __z88dk_fastcall {
  srand(14 + startLevel);
  gameMode();
  setupGameStats();
  if(startLevel > 0) {
    currentStats.level = startLevel - 1; // gets incremented right below
  }

  initJeffs();
  initBombs();

  nextLevel(1);

  byte loopCount = 0;
  byte pause = 0;

  while(1) {
    do {
      intrinsic_halt();
      ++currentStats.frames;

      byte pressed = readKeyboardLetter();

      if(++loopCount == 6) {
        updateStatus();
        loopCount = 0;

      } else if(loopCount==3) {
        if(pressed=='Z') {
          mouseState.wheel = 1;
        } else if(pressed=='X') {
          mouseState.wheel = -1;
        }
      }

      if(inputDelay) {
        --inputDelay;

      } else if(pressed) {
        if(pressed=='P') {
          inputDelay = SMALL_INPUT_DELAY;
          pause = 1;
          status("PAUSE");

        } else if(pressed=='Q') {
          inputDelay = SMALL_INPUT_DELAY;
          return 0; // game over

        } else if(pause) {
          inputDelay = SMALL_INPUT_DELAY;
          pause = 0;
          pauseKeys(pressed);
        }
      }

      updateMouse();

    } while(pause);

    updateBombs();
    updateJeffs();
    updateBonuses();

    byte statResults = processGameStats();
    switch(statResults) {
      case 1:
        // game over
        return 0;

      case 2:
        // level complete
        nextLevel(0);
        break;

      default:
        updateStatsIfNeeded();
        break;
    }
  }
}
