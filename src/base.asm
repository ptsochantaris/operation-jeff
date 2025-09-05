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

GLOBAL _mouseHwX, _mouseHwY, _mouseHwB

isr:
    push af
    push bc

    ld bc, $fbdf
    in a, (c)
    ld (_mouseHwX), a

    ld b, $ff
    in a, (c)
    ld (_mouseHwY), a

    ld b, $fa
    in a, (c)
    ld (_mouseHwB), a

    pop bc
    pop af
    ei
    ret

SECTION PAGE_28_POSTISR
org 0x57
