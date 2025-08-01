#include "resources.h"

void hideSprite(byte index) __z88dk_fastcall {
  ZXN_NEXTREGA(0x34, index); // sprite index
  ZXN_NEXTREG(0x38, 0); // invisible
}

void updateSprite(struct sprite_info *restrict s) __z88dk_fastcall {
  ZXN_NEXTREGA(0x34, s->index); // sprite index
  struct coord pos = s->pos;

  int targetX = pos.x;
  int targetY = pos.y - pos.z;

  byte scaleUp = s->scaleUp;
  if(scaleUp) {
    targetX -= 8;
    targetY -= 8;
  }
  if(targetY < 0) targetY = 0;

  ZXN_NEXTREGA(0x35, targetX & 0xFF); // x low
  int value = (s->horizontalMirror ? 8 : 0) | targetX >> 8; // x high
  ZXN_NEXTREGA(0x37, value);
  ZXN_NEXTREGA(0x36, targetY & 0xFF); // y low
  value = (scaleUp ? 0xA : 0) | targetY >> 8; // y high
  ZXN_NEXTREGA(0x39, value);
  ZXN_NEXTREGA(0x38, 0xC0 | s->pattern); // 1'0'PPPPPP ; sprite visible, using pattern
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

static const struct ResourceInfo rR = R_sprites_spr;
static const struct ResourceInfo rP = R_default_nxp_zx0;

void loadSprites(void) __z88dk_fastcall {  
  ZXN_NEXTREG(REG_SPRITE_TRANSPARENCY_INDEX, 0); // sprite palette index 0 is transparent

  ZXN_WRITE_MMU1(rR.page);
  ZXN_WRITE_MMU2(rR.page+1);
  dmaMemoryToPort((byte *)rR.resource, __IO_SPRITE_PATTERN, rR.length);

  uploadPalette(&rP, 512, 2);
}
