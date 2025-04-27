#include "resources.h"

extern const byte *keyboardLookup;
extern const word *keyboardPorts;

byte readKeyboardLetter(void) __z88dk_fastcall {
    const word *end = keyboardPorts+9;
    const byte *offset = keyboardLookup;
    byte shifted = 0;
    byte v = 0;

    for(const word *port = keyboardPorts; port != end; ++port) {
        word pressed = z80_inp(*port);
        for(byte i=0; i!=5; ++i) {
            if((pressed & 1) == 0) {
                byte r = *offset;
                if(r==1) {
                    shifted = 1;
                } else {
                    v = r;
                }
            }
            pressed = pressed >> 1;
            ++offset;
        }
    }
    if(shifted && v=='0') {
        return 8; // backspace
    }
    return v;
}
