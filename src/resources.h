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

extern void decompressZX0(byte *src, byte *dst) __z88dk_callee __smallc;
extern void writeNextReg(byte reg, const char *bytes, byte len) __preserves_regs(iyh,iyl) __z88dk_callee __smallc;
extern void updateSprite(struct sprite_info *restrict s) __preserves_regs(iyh,iyl) __z88dk_fastcall;
extern void selectPalette(byte paletteMask) __preserves_regs(b,c,d,e,h,iyh,iyl) __z88dk_fastcall;
extern int random16(void) __preserves_regs(b,c,d,e,iyh,iyl) __z88dk_fastcall;

extern void print(byte *text, word x, byte y, byte textColor, byte bgColor) __z88dk_callee __smallc;
extern void printNoBackground(byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;
extern void printSidewaysNoBackground(const byte *text, word x, byte y, byte textColor) __z88dk_callee __smallc;

#endif

// z88dk index: https://github.com/z88dk/z88dk/blob/master/doc/ZXSpectrumZSDCCnewlib_GettingStartedGuide.md
