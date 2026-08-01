#ifndef __TILEMAP_H__
#define __TILEMAP_H__

// We're moving MMU2, which contains ULA and the tilemap, to MMU3
// leaving MMU2 free to act as a buffer extension for MMU1

// 0x6000 is filled the tilemap definition original data (tiles.asm) on load (page 11)
// but we cover it my mapping the ULA (page 10), normally at MMU2, over it at MMU3
// The tilemap still reads from the unmapped page 11
#define ula 0x6000
#define ulaAttributes ula + 0x1800

// So the tilemap that would normally be at 0x5b00 is now 0x2000 bytes higher
#define tilemapAddress 0x5B00 + 0x2000
#define tilemapLength 40 * 32

void initTilemap(void) __z88dk_fastcall;

// Stamps (1) or lifts (0) a kill-radius disc of tiles centred on a playfield
// coordinate. Draw and clear must be paired, same x and y.
void tilemapFlash(word x, word y, byte active) __z88dk_callee;

#endif
