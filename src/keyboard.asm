SECTION PAGE_28_POSTISR

GLOBAL joystickButtons, _keyboardShiftPressed, _keyboardSymbolShiftPressed

keyboardLookup:
    DB '1', '2', '3', '4', '5', '0', '9', '8', '7', '6'
    DB 'Q', 'W', 'E', 'R', 'T', 'P', 'O', 'I', 'U', 'Y'
    DB 'A', 'S', 'D', 'F', 'G',  13, 'L', 'K', 'J', 'H'
    DB   1, 'Z', 'X', 'C', 'V', ' ',   2, 'M', 'N', 'B'
    DB   0 ; zero end sentinel

readKeyboardStartButton:
    ld l, 'P'
    ret

PUBLIC _readKeyboardLetter
_readKeyboardLetter:
    ld a, (joystickButtons)
    and 8
    jr nz, readKeyboardStartButton ; tail recurses return for this

    ; a = 0 or we wouldn't be here
    ld l, a
    ld (_keyboardShiftPressed), a
    ld (_keyboardSymbolShiftPressed), a

    ld de, keyboardLookup

    ; keyboard port MSBs
    ld a, $f7
    call readKeyboardRow
    ld a, $ef
    call readKeyboardRow
    ld a, $fb
    call readKeyboardRow
    ld a, $df
    call readKeyboardRow
    ld a, $fd
    call readKeyboardRow
    ld a, $bf
    call readKeyboardRow
    ld a, $fe
    call readKeyboardRow
    ld a, $7f
    ; fallthrough

readKeyboardRow:
    in a, ($fe) ; input from keyboard port $(MSB)FE
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
    ret
