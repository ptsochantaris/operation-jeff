#ifndef __FILES_H__
#define __FILES_H__

#include "types.h"

void esxDosRomSetup(void);
void persistData(byte *src, int len);
void fetchData(byte *dst, int len);

#endif
