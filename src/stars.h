#ifndef _STARS_H_
#define _STARS_H_

typedef struct {
  word x;
  byte y;
  byte speed;
} star;

void initStars(void) __z88dk_fastcall;
void updateStars(void) __z88dk_fastcall;

#endif