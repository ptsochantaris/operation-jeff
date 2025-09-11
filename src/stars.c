#include "resources.h"

#define starCount 40

static struct star stars[starCount];

void initStars(void) __z88dk_fastcall {
    for(byte f=0; f!=starCount; ++f) {
        struct star *s = stars+f;
        s->x = random16() % 320;
        s->y = random16() % 256;
        s->speed = 1 + random16() % 7;
    }
}

void updateStars(void) __z88dk_fastcall {
    for(byte f=0; f!=starCount; ++f) {
        struct star *s = stars+f;
        word x = s->x;
        byte y = s->y;
        byte sp = s->speed;

        layer2Plot(x, y, 0);

        if(x < sp) {
            x = 319;
            y = random16() % 256;
            sp = 1 + random16() % 7;
            s->y = y;
            s->speed = sp;
        } else {
            x -= sp;
        }

        layer2Plot(x, y, sp);
        s->x = x;
    }
}
