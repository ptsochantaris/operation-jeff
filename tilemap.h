#ifndef __TILEMAP_H__
#define __TILEMAP_H__

#define tilemapAddress (0x4000 + 0x1800 + 0x300)
#define tilemapLength 40 * 32
#define tilemapDefinitionsAddress tilemapAddress + tilemapLength

void initTilemap(void) __z88dk_fastcall;
void clearTilemap(void) __z88dk_fastcall;

#endif
