#include "base.h"

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

  fadePaletteDown(1, 1, 0);

  gameMode();

  const struct LevelInfo info = levelInfo[newLevel];
  loadScreen(&info);
  loadHeightmap(&info);

  effectSiren();

  statsInitLevel();

  selectPalette(1);
  loadPaletteBuffer(&(info.paletteAsset));
  initHud(newLevel); // also stashes it own palette entries
  fadeExistingPaletteUp();

  selectPalette(2);
  writeColourToIndex(info.jeffDark, 128);
  writeColourToIndex(info.jeffBright, 224);

  sprintf(textBuf, "ZONE %02d", newLevel + 1);
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
  if(keyboardSymbolShiftPressed && keyboardShiftPressed && key == 'N') {
    nextLevel(0);
    return;
  }
  
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
    return;
  }

  status("GO");
}

void randomZap(void) {
  int r = currentStats.zapLocation.z;
  int d = r << 1;

  int x = currentStats.zapLocation.x;
  int low = x - r;
  int high;
  if(low < 8) { 
    low = 8;
    high = 8 + d;
  } else {
    high = x + r;
    if(high > 311) { 
      high = 311;
      low = 311 - d;
    }
  }
  x = low + (random16() % d);

  int y = currentStats.zapLocation.y;
  low = y - r;
  if(low < 8) { 
    low = 8;
    high = 8 + d;
  } else {
    high = y + r;
    if(high > 246) { 
      high = 246;
      low = 246 - d;
    }
  }
  y = low + (random16() % d);

  bombIfPossible(x, y);
}

void updateZap(void) __z88dk_fastcall {
  const int radius = currentStats.zapLocation.z;
  if(radius == 0) {
    return;
  }

  if(radius > 100) {
    currentStats.zapLocation.z = 0;
    effectBombLightEnd();
    return;
  }

  randomZap();
  currentStats.zapLocation.z++;
  randomZap();
}

void gameLoop(byte startLevel) __z88dk_fastcall {
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
      updateMouse();

      ++currentStats.frames;

      byte pressed = readKeyboardLetter();

      if(++loopCount == 6) {
        updateStatus();
        loopCount = 0;

      } else if(loopCount == 2) {
        switch(pressed) {
          case 'Z':
            mouseState.wheel = 1;
            break;

          case 'X':
            mouseState.wheel = -1;
            break;
        }
      } else if(loopCount == 4) {
        updateZap();
      }

      if(inputDelay) {
        --inputDelay;

      } else {
        switch(pressed) {
          case 0:
            break;

          case 'Q':
            inputDelay = SMALL_INPUT_DELAY;
            return; // game over

          case 'P':
            if(!pause) { // else fallthrough
              inputDelay = SMALL_INPUT_DELAY;
              pause = 1;
              status("PAUSE");
              break;
            }

          default:
            if(pause) {
              inputDelay = SMALL_INPUT_DELAY;
              pause = 0;
              pauseKeys(pressed);
              break;
            }
        }
      }
    } while(pause);

    updateBombs();
    updateJeffs();
    updateBonuses();

    byte statResults = processGameStats();
    switch(statResults) {
      case 1:
        // game over
        return;

      case 2:
        // level complete
        nextLevel(0);
        break;

      default:
        updateStatsIfNeeded();
        copperCycle();
        break;
    }
  }
}
