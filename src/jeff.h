#ifndef _JEFF_H_
#define _JEFF_H_

#include "types.h"

extern byte heightMap[];

void initJeffs(void) __z88dk_fastcall;
void updateJeffs(void) __z88dk_fastcall;
void jeffKillAll(void) __z88dk_fastcall;

#endif
