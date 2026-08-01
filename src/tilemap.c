#include "base.h"

static const byte tilemapPalette[] = {
  COLOR9(0, 0, 0), // 0 All black
  COLOR9(7, 0, 0), // 1 All red
  COLOR9(0, 7, 0), // 2 All green
  COLOR9(0, 0, 7), // 3 All blue
  COLOR9(7, 7, 0), // 4 All yelow
  COLOR9(1, 1, 1), // 5 Off black
  COLOR9(3, 3, 3), // 6 Gray
  COLOR9(7, 7, 7), // 7 White
  COLOR9(1, 2, 7), // 8 Lilac
  COLOR9(7, 4, 1), // 9 Orange
  COLOR9(7, 7, 1), // A Off yellow
  COLOR9(4, 0, 4), // B Pink
  COLOR9(0, 0, 0), // C (pending)
  COLOR9(0, 0, 0), // D (pending)
  COLOR9(0, 0, 0)  // E (pending)
                   // F Transparent
};

void initTilemap(void) __z88dk_fastcall {
  ZXN_NEXTREG(0x6B, 0xA0); // 1010 0000, enable tilemap, 40x32, global attribute, palette 1, 256 tile mode, tilemap under ULA
  ZXN_NEXTREG(0x6C, 0x01); // 0000 0001, no palette offset, no x mirror, no y mirror, no rotation, ula over tilemap
  ZXN_NEXTREG(0x4C, 0x0F); // index F as transparent
  ZXN_NEXTREGA(0x6E, tilemapAddress >> 8);
  ZXN_NEXTREGA(0x6F, 0x60); // MSB of tilemap definitions, at 0x6000

  writeNextReg(0x1B, clipBytes, CLIPBYTES_LEN);

  // Upoad palette
  selectPalette(3);
  ZXN_NEXTREG(REG_PALETTE_INDEX, 0);
  writeNextReg(REG_PALETTE_VALUE_16, tilemapPalette, sizeof(tilemapPalette));

  // Fast clear
  ZXN_WRITE_MMU3(11);
  fillWithDma(tilemapAddress, tilemapLength, 0);

  // Map ULA (page 10) to 0x6000 instead of 0x4000
  ZXN_WRITE_MMU3(10);
  scrollTilemap(0, 0);
}

// The tilemap is the only layer that spans the whole play area: 40x32 cells of
// 8x8 over the full 320x256, where the ULA only reaches the middle 256x192 and
// leaves blasts near an edge with half a disc. It sits under the ULA and over
// layer 2 (initTilemap above, plus gameMode's SUL), so the flash still passes
// beneath the sprites and the jeffs stay visible dying inside it.
//
// Cell mapping inverts the one bonus.c uses on the way in - it hands over
// (column << 3) - 4 - so the disc lands exactly on the tile that triggered it.
#define FLASH_FILL_TILE 29
#define FLASH_EDGE_TILE 30
#define TILEMAP_COLUMNS 40
#define TILEMAP_ROWS 32

// Half-width in cells per row of a 60 pixel (7.5 cell) radius disc, the same
// radius jeffKillAllAt kills within. Indexed by distance from the middle row.
static const byte flashSpan[] = { 7, 7, 7, 7, 6, 6, 4, 3 };
#define FLASH_SPAN_COUNT 8

void tilemapFlash(word x, word y, byte active) __z88dk_callee {
  const int cx = ((int)x + 4) >> 3;
  const int cy = ((int)y + 4) >> 3;

  // Clearing puts back tile 0, which is fully transparent: during play the only
  // other thing on the tilemap is the single bonus tile, and bonus.c replaces
  // that itself once the hit has been processed.
  const byte fill = active ? FLASH_FILL_TILE : 0;
  const byte edge = active ? FLASH_EDGE_TILE : 0;

  ZXN_WRITE_MMU3(11);
  for(int r = 1 - FLASH_SPAN_COUNT; r != FLASH_SPAN_COUNT; ++r) {
    const int row = cy + r;
    if((word)row >= TILEMAP_ROWS) continue;

    const byte distance = (r < 0) ? -r : r;
    const byte half = flashSpan[distance];
    int left = cx - half;
    int right = cx + half;
    if(left < 0) left = 0;
    if(right >= TILEMAP_COLUMNS) right = TILEMAP_COLUMNS - 1;
    if(right < left) continue;

    // The top and bottom rows are all rim; the rest carry it in their end cells
    const byte body = (distance == FLASH_SPAN_COUNT-1) ? edge : fill;
    byte *t = (byte *)tilemapAddress + row * TILEMAP_COLUMNS + left;
    for(byte c = right - left + 1; c; --c) {
      *t++ = body;
    }

    if(body == fill) {
      *(t-1) = edge;
      *((byte *)tilemapAddress + row * TILEMAP_COLUMNS + left) = edge;
    }
  }
  ZXN_WRITE_MMU3(10);
}
