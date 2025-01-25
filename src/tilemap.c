#include "resources.h"

const byte tilemapPalette[] = {
  COLOR9(0, 0, 0),
  COLOR9(7, 0, 0),
  COLOR9(0, 7, 0),
  COLOR9(0, 0, 7),
  COLOR9(7, 7, 0),
  COLOR9(1, 1, 1),
  COLOR9(3, 3, 3),
  COLOR9(7, 7, 7)
};

void initTilemap(void) __z88dk_fastcall {
  ZXN_NEXTREG(0x6B, 0xA0); // 1010 0000, enable tilemap, 40x32, global attribute, palette 1, 256 tile mode, tilemap under ULA
  ZXN_NEXTREG(0x6C, 0x01); // 0000 0001, no palette offset, no x mirror, no y mirror, no rotation, ula over tilemap
  ZXN_NEXTREG(0x4C, 0x0F); // index F as transparent
  ZXN_NEXTREGA(0x6E, tilemapAddress >> 8);
  ZXN_NEXTREGA(0x6F, tilemapDefinitionsAddress >> 8);

  writeNextReg(0x1B, clipBytes, CLIPBYTES_LEN);

  uploadPalette(tilemapPalette, 16, 3, 28);
}

void clearTilemap(void) __z88dk_fastcall {
  fillWithDma(tilemapAddress, tilemapLength, 0); // zero out tilemap
}
