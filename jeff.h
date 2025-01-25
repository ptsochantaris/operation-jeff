#ifndef _JEFF_H_
#define _JEFF_H_

void initJeffs(void) __z88dk_fastcall;
void updateJeffs(void) __z88dk_fastcall;
void jeffKillAll(void) __z88dk_fastcall;
byte *darkJeffColor(byte level) __z88dk_fastcall;
byte *brightJeffColor(byte level) __z88dk_fastcall;

#endif
