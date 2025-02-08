#ifndef __TILEMAP_H__
#define __TILEMAP_H__

// 0x6000 is filled the original data at tilemapDefinitionsAddress on load (page 11)
#define tilemapDefinitionsAddress 0x6000

// then we cover it my mapping the ULA, page 10, over it - so Z80 sees it at 0x6000 instead of 0x4000
#define ula 0x6000
#define ulaAttributes ula + 0x1800

// So tilemap would normally be at 0x5b00 but we map this 0x2000 bytes higher
#define tilemapAddress 0x5B00 + 0x2000
#define tilemapLength 40 * 32

void initTilemap(void) __z88dk_fastcall;
void clearTilemap(void) __z88dk_fastcall;
void scrollTilemap(word x, byte y) __z88dk_callee;

#endif
