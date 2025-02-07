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

#define SCREEN_ARRAY(X) \
    &R_##X##_0_nxi_zx0, \
    &R_##X##_1_nxi_zx0, \
    &R_##X##_2_nxi_zx0, \
    &R_##X##_3_nxi_zx0, \
    &R_##X##_4_nxi_zx0, \
    &R_##X##_5_nxi_zx0, \
    &R_##X##_6_nxi_zx0, \
    &R_##X##_7_nxi_zx0, \
    &R_##X##_8_nxi_zx0, \
    &R_##X##_9_nxi_zx0

extern void decompressZX0(byte *dst, byte *src) __z88dk_callee __smallc;

#endif
