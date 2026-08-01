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

//////////////////////////////////// Minibomb flash

// Cell mapping inverts the one bonus.c uses on the way in - it hands over
// (column << 3) - 4 - so the disc lands exactly on the tile that triggered it.
#define TILEMAP_COLUMNS 40
#define TILEMAP_ROWS 32
#define FLASH_FIRST_ROW 2
#define FLASH_FIRST_COLUMN 2
#define FLASH_SPAN_COUNT 8

// Half-width in cells per row of a 60 pixel (7.5 cell) radius disc, the same
// radius jeffKillAllAt kills within. Indexed by distance from the middle row.
static const byte flashSpan[] = { 7, 7, 7, 7, 6, 6, 4, 3 };

// Assembled by tiles.asm as (_laserTiles - _tilesBase) / 32. The index is the
// symbol's value, not its contents, so taking the address is what reads it -
// and it costs an immediate load instead of a runtime subtract and shift.
extern byte laserTileIndex;
#define LASER_TILE ((byte)(word)&laserTileIndex)

void tilemapFlash(word x, word y, byte active) __z88dk_callee {
  const int cx = ((int)x + 4) >> 3;
  const int cy = ((int)y + 4) >> 3;

  const byte fill = active ? LASER_TILE : 0;
  const byte edge = active ? (fill + 1) : 0;

  ZXN_WRITE_MMU3(11);
  for(int r = 1 - FLASH_SPAN_COUNT; r != FLASH_SPAN_COUNT; ++r) {
    const int row = cy + r;
    // one unsigned compare rejects both a row above the HUD and one off the foot
    if((word)(row - FLASH_FIRST_ROW) >= (TILEMAP_ROWS - FLASH_FIRST_ROW)) continue;

    const byte distance = (r < 0) ? -r : r;
    const byte half = flashSpan[distance];
    int left = cx - half;
    int right = cx + half;

    // A clamped end is a straight cut through the disc, not part of its outline,
    // so it keeps the fill: rimming it would bulge the silhouette out to the
    // screen edge instead of letting the circle simply run off it.
    const byte leftCut = (left < FLASH_FIRST_COLUMN);
    if(leftCut) left = FLASH_FIRST_COLUMN;
    const byte rightCut = (right >= TILEMAP_COLUMNS);
    if(rightCut) right = TILEMAP_COLUMNS - 1;
    if(right < left) continue;

    // The top and bottom rows are all rim; the rest carry it in their end cells
    const byte body = (distance == FLASH_SPAN_COUNT-1) ? edge : fill;
    byte *t = (byte *)tilemapAddress + row * TILEMAP_COLUMNS + left;
    for(byte c = right - left + 1; c; --c) {
      *t++ = body;
    }

    if(body == fill) {
      if(!rightCut) *(t-1) = edge;
      if(!leftCut) *((byte *)tilemapAddress + row * TILEMAP_COLUMNS + left) = edge;
    }
  }
  ZXN_WRITE_MMU3(10);
}
