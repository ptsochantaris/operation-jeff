#include <z80.h>
#include "sound.h"

// Precalc'ed AY pitches for 3.5 MHz (218750 / note drequency)
static const word notePitches[] = {
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

void ayChipSelect(byte chip) __z88dk_fastcall { // 0 - 2
    z80_outp(0xFFFD, 0xFC | (3 - chip)); // first AY on both channels
}

void aySetPitch(word channel, word pitch) __z88dk_callee { // 0 - 4095
    word reg = channel << 1;
    z80_outp(0xFFFD, reg);
    z80_outp(0xBFFD, pitch & 0xFF);

    z80_outp(0xFFFD, reg+1);
    z80_outp(0xBFFD, 0xF & (pitch >> 8));
}

void ayPlayNote(word channel, enum NoteIndex note) __z88dk_callee { // 0 - 4095
    aySetPitch(channel, notePitches[note]);
}

void aySetAmplitude(word channel, word volume) __z88dk_callee { // 0 - 15 (16 = use envelope)
    word reg = 8 + channel;
    z80_outp(0xFFFD, reg);
    z80_outp(0xBFFD, volume);
}

void aySetEnvelope(word type, word duration) __z88dk_callee { // 0 - 15, 0 - 65535
    /*
    0       \__________     single decay then off

    4       /|_________     single attack then off

    8       \|\|\|\|\|\     repeated decay

    10      \/\/\/\/\/\     repeated decay-attack
              _________
    11      \|              single decay then hold

    12      /|/|/|/|/|/     repeated attack
             __________
    13      /               single attack then hold

    14      /\/\/\/\/\/     repeated attack-decay
    */

    z80_outp(0xFFFD, 11);
    z80_outp(0xBFFD, duration & 0xFF);

    z80_outp(0xFFFD, 12);
    z80_outp(0xBFFD, duration >> 8);

    z80_outp(0xFFFD, 13);
    z80_outp(0xBFFD, type & 0xF);
}

void aySetNoise(word speed) __z88dk_fastcall { // 0 - 31
    z80_outp(0xFFFD, 6);
    z80_outp(0xBFFD, 0x1F & speed);
}

void aySetMixer(word channel, word tone, word noise) __z88dk_callee {
    z80_outp(0xFFFD, 7);
    int existing = z80_inp(0xFFFD);
    if(tone) {
        existing &= ~(1 << channel);
    } else {
        existing |= (1 << channel);
    }
    if(noise) {
        existing &= ~(8 << channel);
    } else {
        existing |= (8 << channel);
    }
    z80_outp(0xBFFD, existing);
}

void ayStopAllSound(void) __z88dk_fastcall {
    for(byte ayChip=0; ayChip<3; ++ayChip) {
        ayChipSelect(ayChip);
        for(byte channel=0; channel<3; ++channel) {
          aySetMixer(channel, 0, 0);
          aySetAmplitude(channel, 0x0);
        }
      }
}
