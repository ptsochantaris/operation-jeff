#include "resources.h"

void wait(byte time) __z88dk_fastcall {
  for(byte f=0;f!=time;f++) {
    intrinsic_halt();
  }
}

byte isShifted(void) __z88dk_fastcall {
  return (z80_inp(0xfefe) & 1) == 0;
}

#ifdef DEBUG_KEYS
byte debugKeys(void) __z88dk_fastcall {
  byte pressed = z80_inp(0x7ffe);
  if((pressed & 1) == 0) { // space
    inputDelay = SMALL_INPUT_DELAY;
    return 2;
  }
  
  pressed = z80_inp(0xf7fe);
  for(byte l=0;l!=6;++l) { // 0...5
    if((pressed & (1 << l)) == 0) {
      inputDelay = SMALL_INPUT_DELAY;
      currentStats.level = isShifted() ? (l + 9) : (l - 1);
      nextLevel(0);
      return 0;
    }
  }

  pressed = z80_inp(0xeffe);
  for(byte l=0;l!=5;++l) { // 10...6
    if((pressed & (1 << l)) == 0) {
      inputDelay = SMALL_INPUT_DELAY;
      currentStats.level = isShifted() ? (18 - l) : (8 - l);
      nextLevel(0);
      return 0;
    }
  }

  //pressed = z80_inp(0xfdfe);
  //pressed = z80_inp(0xfbfe);
  //pressed = z80_inp(0xbffe);

  return 0;
}
#endif

void nextLevel(byte gameStart) __z88dk_fastcall {
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

  fadePaletteDown(1, 512);

  gameMode();

  const struct LevelInfo info = levelInfo[newLevel];
  loadScreen(&info);
  loadHeightmap(&info);

  statsInitLevel();
  initHud(newLevel);

  effectSiren();

  fadePaletteUp(&(info.paletteAsset), nonHudPaletteByteCount, 1);

  selectPalette(2);
  writeColourToIndex(info.jeffDark, 128);
  writeColourToIndex(info.jeffBright, 224);

  sprintf(textBuf, "ZONE %03d", newLevel + 1);
  status(textBuf);
}

void gameMode(void) __z88dk_fastcall {
  ayStopAllSound();
  setSpriteGameClipping();
  setGameMouse();
  setupLayers(2); // SUL
  ulaAttributeClear();
  mouseReset();
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

      if(++loopCount == 6) {
        updateStatus();
        loopCount = 0;

      } else if(loopCount==3) {
        byte pressed;
        pressed = z80_inp(0xfefe);
        if((pressed & 2) == 0) { // z
          mouseState.wheel = 1;
        }
        if((pressed & 4) == 0) { // x
          mouseState.wheel = -1;
        }
      }

      if(inputDelay) {
        --inputDelay;
      } else {
        byte pressed = z80_inp(0xdffe);
        if((pressed & 1) == 0) { // p
          inputDelay = SMALL_INPUT_DELAY;
          pause = !pause;
          status(pause ? "PAUSED" : NULL);
        }
        #ifdef DEBUG_KEYS
        byte k = debugKeys();
        if(k==1) {
          return 1;
        } else if(k==2) {
          currentStats.level = currentStats.level + 1;
          nextLevel(0);
          continue;
        }
        #endif
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
