#include "resources.h"

extern const byte keyboardLookup[];

static const word keyboardPorts[] = { 0xf7fe, 0xeffe, 0xfbfe, 0xdffe, 0xfdfe, 0xbffe, 0xfefe, 0x7ffe };

byte keyboardShiftPressed = 0;
byte keyboardSymbolShiftPressed = 0;

byte readKeyboardLetter(void) __z88dk_fastcall {
    const word *end = keyboardPorts+8;
    const byte *character = keyboardLookup;
    byte shifted = 0;
    byte symbolShifted = 0;
    byte letter = 0;

    for(const word *port = keyboardPorts; port != end; ++port) {
        word pressed = z80_inp(*port);
        for(byte i=0; i!=5; ++i) {
            if((pressed & 1) == 0) {
                byte r = *character;
                if(r==1) {
                    shifted = 1;
                } else if(r==2) {
                    symbolShifted = 1;
                } else {
                    letter = r;
                }
            }
            pressed = pressed >> 1;
            ++character;
        }
    }
    keyboardSymbolShiftPressed = symbolShifted;
    keyboardShiftPressed = shifted;
    if(shifted && letter=='0') {
        return 8; // backspace
    }
    return letter;
}
