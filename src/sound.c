#include <z80.h>
#include "sound.h"

extern const word notePitches[];

void ayChipSelect(byte chip) __z88dk_fastcall { // 0 - 2
    z80_outp(0xFFFD, 0xFC | (3 - chip)); // first AY on both channels
}

void aySetPitch(word channel, word pitch) { // 0 - 4095
    word reg = channel << 1;
    z80_outp(0xFFFD, reg);
    z80_outp(0xBFFD, pitch & 0xFF);

    z80_outp(0xFFFD, reg+1);
    z80_outp(0xBFFD, 0xF & (pitch >> 8));
}

void ayPlayNote(word channel, NoteIndex note) { // 0 - 4095
    aySetPitch(channel, notePitches[note]);
}

void aySetAmplitude(word channel, word volume) { // 0 - 15 (16 = use envelope)
    word reg = 8 + channel;
    z80_outp(0xFFFD, reg);
    z80_outp(0xBFFD, volume);
}

void aySetEnvelope(word type, word duration) { // 0 - 15, 0 - 65535
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

void aySetMixer(word channel, word tone, word noise) {
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
