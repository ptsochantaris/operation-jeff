SECTION PAGE_28_POSTISR

GLOBAL keyboardLookup, joystickButtons, keyboardPorts, _keyboardShiftPressed, _keyboardSymbolShiftPressed

.readKeyboardStartButton:
    ld l, 'P'
    ret

PUBLIC _readKeyboardLetter
_readKeyboardLetter:
    ld a, (joystickButtons)
    and 8
    jr nz, readKeyboardStartButton

    ld de, keyboardLookup

    ; a = 0
    ld l, a
    ld (_keyboardShiftPressed), a
    ld (_keyboardSymbolShiftPressed), a

    ld c, $fe   ; keyboard port LSB
    ld iy, keyboardPorts

.readKeyboardLetterLoop:
    ld b, (iy)  ; keyboard port MSB

    ld a, b
    or a
    ret z ; return if we hit the zero sentinel

    in a, (c)
    ld b, 5
.readRowLoop:
    rra
    jp c, noPress

    ; press
    ld h, a
    ld a, (de)
    cp 1
    jp nz, notShifted
    ld (_keyboardShiftPressed), a
.notShifted:
    cp 2
    jp nz, notSymbolShifted
    ld (_keyboardSymbolShiftPressed), a
.notSymbolShifted:
    cp 12
    jp c, notLetter
    ld l, a
.notLetter:
    ld a, h

.noPress:
    inc de
    djnz readRowLoop

    inc iy
    jp readKeyboardLetterLoop
