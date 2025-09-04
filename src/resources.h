#ifndef _RESOURCES_H_
#define _RESOURCES_H_

// #define DEBUG_KEYS

#include <errno.h>
#include <stdint.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <z80.h>
#include <intrinsic.h>
#include <arch/zxn.h>
#include <arch/zxn/copper.h>
#include <config_zxn.h>
#include <compress/zx0.h>
#include <arch/zxn/esxdos.h>

#include "types.h"
#include "dma.h"
#include "screen.h"
#include "sound.h"
#include "tilemap.h"
#include "copper.h"
#include "levelinfo.h"

#include "effects.h"
#include "sprites.h"
#include "hud.h"
#include "leds.h"
#include "bomb.h"
#include "mouse.h"
#include "stats.h"
#include "bonus.h"
#include "game.h"
#include "jeff.h"
#include "menu.h"
#include "gameover.h"
#include "end_of_level.h"
#include "stars.h"
#include "assets.h"
#include "copper.h"
#include "music.h"
#include "files.h"
#include "keyboard.h"

extern void decompressZX0(byte *dst, byte *src) __z88dk_callee __smallc;
extern void selectLayer2Page(byte page) __preserves_regs(b,c,d,h,iyh,iyl) __z88dk_fastcall;
extern void layer2Plot(word x, byte y, byte color) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
extern void layer2CharNoBackground(const byte *restrict glyph, word x, byte y, byte textColor) __z88dk_callee __smallc;
extern void layer2CharSidewaysNoBackground(const byte *restrict glyph, word x, byte y, byte textColor) __z88dk_callee __smallc;
extern void layer2Char(const byte *restrict glyph, word x, byte y, byte textColor, byte bgColor) __z88dk_callee __smallc;
extern void layer2HorizonalLine(word x, word y, word width, byte color) __z88dk_callee __smallc;
extern void layer2VerticalLine(word x, word topY, word bottomY, byte color) __z88dk_callee __smallc;

#endif

// z88dk index: https://github.com/z88dk/z88dk/blob/master/doc/ZXSpectrumZSDCCnewlib_GettingStartedGuide.md
