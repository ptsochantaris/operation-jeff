#include "levelinfo.h"

static LevelInfo l1 = {
    { COLOR9(7, 1, 1) },
    { COLOR9(3, 1, 1) },
    40,
    160,
    100,
    49,
    0
};

static LevelInfo l2 = {
    { COLOR9(4, 7, 4) },
    { COLOR9(0, 6, 0) },
    50,
    160,
    90,
    59,
    1
};

static LevelInfo l3 = {
    { COLOR9(6, 6, 7) },
    { COLOR9(5, 5, 6) },
    60,
    160,
    80,
    69,
    2
};

static LevelInfo l4 = {
    { COLOR9(6, 6, 6) },
    { COLOR9(2, 1, 1) },
    70,
    160,
    70,
    79,
    3
};

static LevelInfo l5 = {
    { COLOR9(7, 6, 5) },
    { COLOR9(6, 4, 1) },
    80,
    160,
    60,
    89,
    4
};

static LevelInfo l6 = {
    { COLOR9(5, 6, 7) },
    { COLOR9(3, 4, 5) },
    90,
    160,
    55,
    99,
    5
};

static LevelInfo l7 = {
    { COLOR9(7, 7, 7) },
    { COLOR9(1, 2, 3) },
    100,
    160,
    50,
    109,
    6
};

static LevelInfo l8 = {
    { COLOR9(5, 7, 2) },
    { COLOR9(1, 5, 1) },
    110,
    160,
    45,
    119,
    7
};

static LevelInfo l9 = {
    { COLOR9(7, 2, 4) },
    { COLOR9(0, 0, 2) },
    120,
    160,
    40,
    129,
    8
};

static LevelInfo l10 = {
    { COLOR9(1, 1, 1) },
    { COLOR9(0, 0, 0) },
    130,
    160,
    40,
    139,
    9
};

LevelInfo *levelInfo[] = { &l1, &l2, &l3, &l4, &l5, &l6, &l7, &l8, &l9, &l10 };
