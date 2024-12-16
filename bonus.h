#ifndef __BONUS_H__
#define __BONUS_H__

#define BONUS_NONE 0
#define BONUS_HEALTH 1
#define BONUS_CHARGE 2
#define BONUS_SCORE 3
#define BONUS_SMARTBOMB 4
#define BONUS_MAX 4

void updateBonuses(void) __z88dk_fastcall;
void resetBonuses(void) __z88dk_fastcall;

#endif
