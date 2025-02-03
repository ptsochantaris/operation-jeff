#include "resources.h"

void hideSprite(byte index) __z88dk_fastcall {
  ZXN_NEXTREGA(0x34, index); // sprite index
  ZXN_NEXTREGA(0x38, 0); // invisible
}

void updateSprite(sprite_info *restrict s) __z88dk_fastcall {
  ZXN_NEXTREGA(0x34, s->index); // sprite index
  ZXN_NEXTREGA(0x35, s->pos.x & 0xFF); // x low
  ZXN_NEXTREGA(0x36, s->pos.y & 0xFF); // y low
  ZXN_NEXTREGA(0x37, s->attrs | (s->pos.x >> 8) & 1); // x high, default attrs
  ZXN_NEXTREGA(0x38, 0xC0 | s->pattern); // 1'0'PPPPPP ; sprite visible, using pattern 00000
  ZXN_NEXTREGA(0x39, (s->pos.y >> 8) & 1); // y high
}

void setSpriteGameClipping(void) __z88dk_fastcall {
  const byte gameClipBytes[] = {8,159,16,255};
  writeNextReg(0x19, gameClipBytes, 4);
}

void setSpriteMenuClipping(void) __z88dk_fastcall {
  writeNextReg(0x19, clipBytes, CLIPBYTES_LEN);

  for(byte f=0; f!=127; ++f) {
    hideSprite(f);
  }
}

extern const byte default_palette;

void loadSprites(void) __z88dk_fastcall {  
  ZXN_NEXTREG(0x4b, 0); // sprite palette index 0 is transparent

  ZXN_WRITE_MMU1(191);
  ZXN_WRITE_MMU2(192);
  dmaMemoryToPort((const byte *)0x2000, __IO_SPRITE_PATTERN, 0x4000);

  uploadPalette(&default_palette, 512, 2, 210);
}
