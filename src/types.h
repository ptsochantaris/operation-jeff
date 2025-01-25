#ifndef _TYPES_H_
#define _TYPES_H_

#include <stdint.h>

#define byte uint8_t
#define word uint16_t

typedef struct {
    int x;
    int y;
} coord;

#define COLOR9(r,g,b) (byte)(r << 5) | (byte)(g << 2) | (byte)(b >> 1), (byte)(b & 1)

#endif
