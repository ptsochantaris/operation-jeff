#ifndef __FILES_H__
#define __FILES_H__

#include "types.h"

void esxDosRomSetup(void) __z88dk_fastcall;
void persistData(void *src, int len) __z88dk_callee;
void fetchData(void *dst, int len) __z88dk_callee;

#endif
