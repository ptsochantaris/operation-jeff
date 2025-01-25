#ifndef __HUD_H__
#define __HID_H__

#define HUD_FILL_LIGHT 247
#define HUD_FILL_DARK 248
#define HUD_BLACK 249
#define HUD_ORANGE 250
#define HUD_YELLOW 251
#define HUD_RED 252
#define HUD_GREEN 253
#define HUD_BLUE 254
#define HUD_WHITE 255

extern byte textBuf[];

void initHud(byte level) __z88dk_fastcall;
void hudEnergyUpdated(void) __z88dk_fastcall;
void hudRateUpdated(void) __z88dk_fastcall;
void hudHealthUpdated(void) __z88dk_fastcall;
void hudScoreUpdated(void) __z88dk_fastcall;
void hudKillsUpdated(void) __z88dk_fastcall;
void print(const byte *restrict text, word x, word y, byte textColor, byte bgColor);
void printNoBackground(const byte *restrict text, word x, word y, byte textColor);
void setHudBackground(int color) __z88dk_fastcall;

#endif
