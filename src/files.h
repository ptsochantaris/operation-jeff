#ifndef __FILES_H__
#define __FILES_H__

#include "types.h"

void esxDosRomSetup(void) __z88dk_fastcall;
void persistData(void *src, int len, const char *restrict filename) __z88dk_callee __smallc;
void fetchData(void *dst, int len, const char *restrict filename) __z88dk_callee __smallc;

#endif
