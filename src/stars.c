#include "resources.h"

#define starCount 40

star stars[starCount];

void initStars(void) __z88dk_fastcall {
    for(byte f=0; f!=starCount; ++f) {
        star *s = stars+f;
        s->x = rand() % 320;
        s->y = rand() % 256;
        s->speed = 1 + rand() % 7;
    }
}

void updateStars(void) __z88dk_fastcall {
    for(byte f=0; f!=starCount; ++f) {
        star *s = stars+f;
        word x = s->x;
        byte y = s->y;
        byte sp = s->speed;

        layer2Plot(x, y, 0);

        if(x < sp) {
            x = 319;
            y = rand() % 256;
            sp = 1 + rand() % 7;
            s->y = y;
            s->speed = sp;
        } else {
            x -= sp;
        }

        layer2Plot(x, y, sp);
        s->x = x;
    }
}
