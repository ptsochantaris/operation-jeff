#include "resources.h"

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
