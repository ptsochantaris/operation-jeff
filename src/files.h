#ifndef __FILES_H__
#define __FILES_H__

#include "types.h"

void esxDosRomSetup(void);
void persistData(void *src, int len);
void fetchData(void *dst, int len);

#endif
