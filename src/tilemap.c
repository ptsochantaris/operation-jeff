#include "resources.h"

static const byte tilemapPalette[] = {
  COLOR9(0, 0, 0),
  COLOR9(7, 0, 0),
  COLOR9(0, 7, 0),
  COLOR9(0, 0, 7),
  COLOR9(7, 7, 0),
  COLOR9(1, 1, 1),
  COLOR9(3, 3, 3),
  COLOR9(7, 7, 7),
  COLOR9(1, 2, 7),
  COLOR9(7, 4, 1),
  COLOR9(7, 7, 1),
};

void initTilemap(void) __z88dk_fastcall {
  ZXN_NEXTREG(0x6B, 0xA0); // 1010 0000, enable tilemap, 40x32, global attribute, palette 1, 256 tile mode, tilemap under ULA
  ZXN_NEXTREG(0x6C, 0x01); // 0000 0001, no palette offset, no x mirror, no y mirror, no rotation, ula over tilemap
  ZXN_NEXTREG(0x4C, 0x0F); // index F as transparent
  ZXN_NEXTREGA(0x6E, tilemapAddress >> 8);
  ZXN_NEXTREGA(0x6F, tilemapDefinitionsAddress >> 8);

  writeNextReg(0x1B, clipBytes, CLIPBYTES_LEN);

  // Upoad palette
  selectPalette(3);
  ZXN_NEXTREG(REG_PALETTE_INDEX, 0);
  writeNextReg(REG_PALETTE_VALUE_16, tilemapPalette, sizeof(tilemapPalette));
}

void clearTilemap(void) __z88dk_fastcall {
  ZXN_WRITE_MMU3(11);
  fillWithDma(tilemapAddress, tilemapLength, 0); // zero out tilemap
  ZXN_WRITE_MMU3(10);
  scrollTilemap(0, 0);
}

void scrollTilemap(word x, byte y) __z88dk_callee {
  ZXN_NEXTREGA(47, x >> 8);
  ZXN_NEXTREGA(48, x & 0xFF);
  ZXN_NEXTREGA(49, y);
}