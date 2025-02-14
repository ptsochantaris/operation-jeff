#include "resources.h"

// Precalc'ed AY pitches for 3.5 MHz (218750 / note drequency)
const word notePitches[] = {
    13379,
    12630,
    11921,
    11247,
    10619,
    10021,
    9462,
    8929,
    8426,
    7955,
    7507,
    7086,

    6690,
    6313,
    5959,
    5625,
    5309,
    5011,
    4730,
    4464,
    4214,
    3977,
    3754,
    3543,

    3344,
    3157,
    2979,
    2812,
    2654,
    2505,
    2365,
    2232,
    2107,
    1989,
    1877,
    1772,

    1672,
    1578,
    1490,
    1406,
    1327,
    1253,
    1182,
    1116,
    1053,
    994,
    939,
    886,

    836,
    789,
    745,
    703,
    664,
    626,
    591,
    558,
    527,
    497,
    469,
    443,

    418,
    395,
    372,
    352,
    332,
    313,
    296,
    279,
    263,
    249,
    235,
    221,

    209,
    197,
    186,
    176,
    166,
    157,
    148,
    140,
    132,
    124,
    117,
    111,

    105,
    99,
    93,
    88,
    83,
    78,
    74,
    70,
    66,
    62,
    59,
    55
};