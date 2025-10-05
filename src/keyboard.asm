SECTION code_compiler

GLOBAL keyboardLookup, joystickButtons

PUBLIC _keyboardShiftPressed, _keyboardSymbolShiftPressed
_keyboardShiftPressed: DB 0
_keyboardSymbolShiftPressed: DB 0

.readKeyboardStart:
    ld l, 'P'
    ret

PUBLIC _readKeyboardLetter
_readKeyboardLetter:
    ld a, (joystickButtons)
    and 8
    jr nz, readKeyboardStart

    ld de, keyboardLookup

    ; a = 0
    ld l, a
    ld (_keyboardShiftPressed), a
    ld (_keyboardSymbolShiftPressed), a

    ld bc, $f7fe
    call readRow
    ld b, $ef
    call readRow
    ld b, $fb
    call readRow
    ld b, $df
    call readRow
    ld b, $fd
    call readRow
    ld b, $bf
    call readRow
    ld b, $fe
    call readRow
    ld b, $7f

.readRow:
    in a, (c)
    ld b, 5
.readRowLoop:
    srl a
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
    RET
