SECTION code_compiler

GLOBAL keyboardLookup

PUBLIC _keyboardShiftPressed
_keyboardShiftPressed: 
    DB 0

PUBLIC _keyboardSymbolShiftPressed
_keyboardSymbolShiftPressed:
    DB 0

PUBLIC _readKeyboardLetter
_readKeyboardLetter:
    ld de, keyboardLookup

    xor a
    ld l, a
    ld (_keyboardShiftPressed), a
    ld (_keyboardSymbolShiftPressed), a

    ld bc, $f7fe
    call readRow
    ld bc, $effe
    call readRow
    ld bc, $fbfe
    call readRow
    ld bc, $dffe
    call readRow
    ld bc, $fdfe
    call readRow
    ld bc, $bffe
    call readRow
    ld bc, $fefe
    call readRow
    ld bc, $7ffe

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
