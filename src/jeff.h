#ifndef _JEFF_H_
#define _JEFF_H_

#include "types.h"

void initJeffs(void) __z88dk_fastcall;
void updateJeffs(void) __z88dk_fastcall;
void jeffKillAll(void) __z88dk_fastcall;
void loadHeightmap(const struct LevelInfo *restrict info) __z88dk_callee;

#endif
