SECTION PAGE_28
ORG 0

PUBLIC _keyboardLookup
_keyboardLookup:
    DEFB '1', '2', '3', '4', '5', '0', '9', '8', '7', '6'
    DEFB 'Q', 'W', 'E', 'R', 'T', 'P', 'O', 'I', 'U', 'Y'
    DEFB 'A', 'S', 'D', 'F', 'G',  13, 'L', 'K', 'J', 'H'
    DEFB   1, 'Z', 'X', 'C', 'V', ' ',   2, 'M', 'N', 'B'

PUBLIC _keyboardPorts
_keyboardPorts:
    DEFW $f7fe, $effe, $fbfe, $dffe, $fdfe, $bffe, $fefe, $7ffe

GLOBAL _mouseX, _mouseY, _mouseHwB, _mouseKempstonX, _mouseKempstonY

isr:
    ex af, af'
    exx

    ; mouse X update

    ld de, (_mouseKempstonX) ; previousX in E
    ld d, 0 ; always stays 0

    ld bc, $fbdf
    in a, (c) ; X
    ld (_mouseKempstonX), a ; store x for next time
    ld h, 0
    ld l, a; currentX in HL
    sbc hl, de ; currentX - previous = dx in HL
    jp z, isrXDone ; no change
    ld a, l ; dx in A for range check
    jp nc, isrPositiveVX

    neg
    cp 100
    JP NC, isrXDone ; ignore abs(dx) greater than 100
    ld hl, (_mouseX)
    ld e, a ; dx in E for subtracting
    sbc hl, de ; currentX - dx
    ld (_mouseX), hl
    jp isrXDone

isrPositiveVX:
    cp 100
    JP NC, isrXDone ; ignore abs(dx) greater than 100
    ld hl, (_mouseX)
    add hl, a ; currentX + dx
    ld (_mouseX), hl
    jp isrXDone

isrXDone:
    ; mouse Y update

    ld de, (_mouseKempstonY) ; previousY in E
    ld d, 0

    ld b, $ff
    in a, (c) ; Y
    ld (_mouseKempstonY), a ; store Y for next time
    ld h, 0
    ld l, a; Y in HL
    sbc hl, de ; currentY - previousV = dy in HL
    jp z, isrYDone
    ld a, l ; dy in A for later
    jp nc, isrPositiveVY

    neg
    cp 100
    JP NC, isrYDone ; ignore abs(dy) greater than 100
    ld hl, (_mouseY)
    add hl, a ; currentY + dy
    ld (_mouseY), hl
    jp isrYDone

isrPositiveVY:
    cp 100
    JP NC, isrYDone ; ignore abs(dy) greater than 100
    ld hl, (_mouseY)
    ld e, a ; dx in E for subtracting
    sbc hl, de ; currentY - dy
    ld (_mouseY), hl
    jp isrYDone

isrYDone:

    ; buttons
    ld b, $fa
    in a, (c)
    ld (_mouseHwB), a

    exx
    ex af, af'
    
    ei
    ret
isrEnd:

SECTION PAGE_28_POSTISR
org isrEnd
