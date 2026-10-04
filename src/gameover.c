#include "base.h"

static void gameOverEffect(void) __z88dk_fastcall {
  ayChipSelect(0);

  aySetEnvelope(0, 0xA000);
  aySetNoise(31);

  aySetPitch(0, 0x500);  
  aySetPitch(2, 0x500);  

  aySetAmplitude(0, 0x10);
  aySetAmplitude(2, 0x10);

  aySetMixer(0, 1, 1);
  aySetMixer(2, 1, 1);
}

static const struct ScreenInfo gameOverInfo = SCREEN_ARRAY(gameOver);
static void loadGameOverScreen(void) __z88dk_fastcall {
  fadeToWhite();
  layer2Clear(0);
  copperEffectFire(); // flames behind the game over / high score screen  
  
  fadePaletteDown(1,3,0);

  loadScreen(gameOverInfo.screens);
  
  fadePaletteUp(&gameOverInfo.palette, 1);
}

static void borderEffectUpdate(void) __z88dk_fastcall {
    word x = 9 + (random16() % (320 - 18));
    word y = random16() % 9;
    layer2Plot(x, y, HUD_MASK);

    x = 9 + (random16() % (320 - 18));
    y = 255 - (random16() % 9);
    layer2Plot(x, y, HUD_MASK);

    x = random16() % 9;
    y = random16() % 255;
    layer2Plot(x, y, HUD_MASK);

    x = 319 - (random16() % 9);
    y = random16() % 255;
    layer2Plot(x, y, HUD_MASK);
}

#define center 159

// The name entry box and its "ENTER YOUR NAME" prompt are painted straight over
// the artwork, so the strips under them are copied out to a spare page first
// and put back once the name is in. The pixels go through MMU2 - fine here, as
// no sample plays on this screen. The stash page has to be written as well as
// read, so it can't sit in MMU0/MMU1: Layer 2 write-through sends every store
// below 0x4000 to the screen instead. It borrows MMU3.
#define STASH ((byte *)0x6000)

#define ENTRY_BOX_COLUMNS (4*10 + 3)
#define ENTRY_BOX_ROWS 9
#define ENTRY_BOX_STASH STASH

#define PROMPT_COLUMNS (4*15)
#define PROMPT_ROWS 5
#define PROMPT_STASH (STASH + ENTRY_BOX_COLUMNS * ENTRY_BOX_ROWS)

static void artworkStrip(byte *stash, word x, word y, byte columns, byte rows, byte restore) __z88dk_callee {
  byte previousMmu3 = mmu3Borrow(ARTWORK_STASH_PAGE);
  do {
    ZXN_WRITE_MMU2(LAYER2_BASE_PAGE + (x >> 5)); // 32 columns per page, 256 bytes each
    byte *pixels = (byte *)(0x4000 + ((x & 31) << 8) + y);
    if(restore) {
      memcpy(pixels, stash, rows);
    } else {
      memcpy(stash, pixels, rows);
    }
    stash += rows;
    ++x;
  } while(--columns);
  mmu3Return(previousMmu3);
}

void gameOverLoop(void) __z88dk_fastcall {
  resetBonuses();
  menuMode();
  status(NULL);
  stopAudioTimer();
  ayStopAllSound();
  gameOverEffect();
  effectGameOverDrone(); // swells up on chips 1 and 2 as the crash on chip 0 decays
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
  word top = 64;
  word promptY = 0;

  print("GAME OVER", x, top, HUD_ORANGE);
  top += 20;

  if(highScoreSlot == HIGHSCORE_SLOTS) {
    x = center - ((4*5) >> 1);
    print("SCORE", x, top, HUD_ORANGE);
    top += 10;

    x = center - ((4*7) >> 1);
    sprintf(textBuf, "%07lu", currentStats.score);
    print(textBuf, x, top, HUD_ORANGE);  

  } else {
    top += 3;
    x = center - ((4*15) >> 1);
    print("NEW HIGH SCORE!", x, top, HUD_WHITE);
    top += 10;
    promptY = top;
    artworkStrip(PROMPT_STASH, x, promptY, PROMPT_COLUMNS, PROMPT_ROWS, 0);
    print("ENTER YOUR NAME", x, top, HUD_WHITE);
  }

  top += 14;
  x = center - ((4*19) >> 1);
  word entryY = displayHighScoreTable(x, top, highScoreSlot);
  if(entryY) {
    artworkStrip(ENTRY_BOX_STASH, x - 2, entryY - 2, ENTRY_BOX_COLUMNS, ENTRY_BOX_ROWS, 0);
    layer2fill(x - 1, entryY - 1, 4*10 + 1, 7, HUD_BLACK);
    layer2roundedBox(x - 2, entryY - 2, 4*10 + 2, 8, HUD_WHITE);
  }

  // The screen is fully drawn and we're about to sit here until the player
  // finishes reading (or typing their name), with no sample playing - so
  // MMU1/MMU2 are ours. Pull the title screen in now and the return to the
  // menu becomes a DMA blit instead of a ~5-12 frame stall.
  prefetchTitleScreen();

  // Starts set, so a key still held from the game has to be let go before it
  // counts - otherwise it would type a letter, or skip the screen outright.
  byte keyDown = 1;

  while(1) {
    waitOne();
    copperEffectUpdate();
    effectGameOverDroneUpdate();

    for(byte i=0; i<8; ++i) {
      borderEffectUpdate();
    }

    if(!entryY && !mouseState.handled) {
      mouseState.handled = 1;
      return;
    }

    byte letter = readKeyboardLetter();
    if(letter < 8) {
      keyDown = 0;
      continue;
    }

    if(keyDown) {
      continue;
    }
    keyDown = 1;

    if(!entryY) {
      // Not editing (any more), so any key leaves. Hold the menu's keyboard
      // off for a moment, or a C or I pressed here would carry straight into it.
      inputDelay = SMALL_INPUT_DELAY;
      return;
    }

    if(letter == '0' && keyboardShiftPressed) {
      if(hiScoreBufPos > 0) {
        hiScoreBuf[--hiScoreBufPos] = ' ';
      }

    } else if(letter == 13) {
      // Name is in: stop editing, but stay on the table until the player
      // chooses to leave. Clicks made while typing don't count as that.
      newHighScore(hiScoreBuf, highScoreSlot);

      // Take the prompt and the box away, leaving the row as plain text like
      // the others, only still in white.
      artworkStrip(PROMPT_STASH, center - ((4*15) >> 1), promptY, PROMPT_COLUMNS, PROMPT_ROWS, 1);
      artworkStrip(ENTRY_BOX_STASH, x - 2, entryY - 2, ENTRY_BOX_COLUMNS, ENTRY_BOX_ROWS, 1);
      print(hiScoreBuf, x, entryY, HUD_WHITE);
      entryY = 0;
      mouseState.handled = 1;
      continue;

    } else {
      if(hiScoreBufPos > 9) {
        hiScoreBufPos = 9;
      }
      hiScoreBuf[hiScoreBufPos++] = letter;
    }

    printWithBackground(hiScoreBuf, x, entryY, HUD_WHITE, HUD_BLACK);
  }
}
