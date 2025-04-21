#include "resources.h"

// #define DEBUG_KEYS

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
    return 1;
  }
  
  pressed = z80_inp(0xf7fe);
  for(byte l=0;l<6;++l) { // 0...5
    if((pressed & (1 << l)) == 0) {
      inputDelay = SMALL_INPUT_DELAY;
      currentStats.level = isShifted() ? (l + 9) : (l - 1);
      nextLevel();
      return 0;
    }
  }

  pressed = z80_inp(0xeffe);
  for(byte l=0;l<5;++l) { // 10...6
    if((pressed & (1 << l)) == 0) {
      inputDelay = SMALL_INPUT_DELAY;
      currentStats.level = isShifted() ? (18 - l) : (8 - l);
      nextLevel();
      return 0;
    }
  }

  //pressed = z80_inp(0xfdfe);
  //pressed = z80_inp(0xfbfe);
  //pressed = z80_inp(0xbffe);

  return 0;
}
#endif

void loadLevelScreen(byte level) __z88dk_fastcall {
  const LevelInfo info = levelInfo[level];

  // flash jeffs white
  selectPalette(2);
  word white = 0x01FF;
  writeColourToIndex(&white, 128);
  writeColourToIndex(&white, 224);

  fadePaletteDown(1, 512);
  loadScreen(&info);
  loadHeightmap(&info);
  initHud(level);

  effectSiren();

  const word nonHudPaletteByteCount = 512-(HUD_COLOUR_COUNT * 2);
  fadePaletteUp(&(info.paletteAsset), nonHudPaletteByteCount, 1);

  selectPalette(2);
  writeColourToIndex(info.jeffDark, 128);
  writeColourToIndex(info.jeffBright, 224);

  sprintf(textBuf, "ZONE %03d", level + 1);
  status(textBuf);
}

void nextLevel(void) __z88dk_fastcall {
  jeffKillAll();
  statsProgressLevel();
  stopDma(); // stop any potential sample, as level loading will use the same buffers
  loadLevelScreen(currentStats.level);
}

byte gameLoop(void) __z88dk_fastcall {
  setSpriteGameClipping();
  setGameMouse();
  setupGameStats();
  ulaAttributeClear();

  setupLayers(2); // SUL
  initJeffs();
  initBombs();
  resetBonuses();

  nextLevel();

  byte loopCount = 0;
  byte pause = 0;

  while(1) {
    do {
      intrinsic_halt();

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
        if(debugKeys()) {
          return 1;
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
        nextLevel();
        break;

      default:
        updateStatsIfNeeded();
        break;
    }
  }
}

//         0     1     2     3     4   Bits  4     3     2     1     0
// F7FE  [ 1 ] [ 2 ] [ 3 ] [ 4 ] [ 5 ]  |  [ 6 ] [ 7 ] [ 8 ] [ 9 ] [ 0 ]   EFFE
// FBFE  [ Q ] [ W ] [ E ] [ R ] [ T ]  |  [ Y ] [ U ] [ I ] [ O ] [ P ]   DFFE
// FDFE  [ A ] [ S ] [ D ] [ F ] [ G ]  |  [ H ] [ J ] [ K ] [ L ] [ ENT ] BFFE
// FEFE  [SHI] [ Z ] [ X ] [ C ] [ V ]  |  [ B ] [ N ] [ M ] [sym] [ SPC ] 7FFE



