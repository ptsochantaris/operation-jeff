#include "levelinfo.h"

static LevelInfo l1 = {
    { COLOR9(7, 1, 1) },
    { COLOR9(3, 1, 1) },
    60,
    180,
    100
};

static LevelInfo l2 = {
    { COLOR9(3, 3, 5) },
    { COLOR9(1, 1, 2) },
    70,
    180,
    95
};

static LevelInfo l3 = {
    { COLOR9(5, 7, 2) },
    { COLOR9(1, 5, 1) },
    80,
    180,
    90
};

static LevelInfo l4 = {
    { COLOR9(6, 6, 6) },
    { COLOR9(2, 1, 1) },
    90,
    180,
    85
};

static LevelInfo l5 = {
    { COLOR9(4, 5, 7) },
    { COLOR9(0, 0, 3) },
    100,
    180,
    80
};

static LevelInfo l6 = {
    { COLOR9(2, 2, 2) },
    { COLOR9(1, 1, 1) },
    110,
    180,
    75
};

static LevelInfo l7 = {
    { COLOR9(7, 7, 7) },
    { COLOR9(1, 2, 3) },
    120,
    180,
    70
};

static LevelInfo l8 = {
    { COLOR9(1, 1, 1) },
    { COLOR9(0, 0, 0) },
    130,
    180,
    65
};

LevelInfo *levelInfo[] = { &l1, &l2, &l3, &l4, &l5, &l6, &l7, &l8 };
