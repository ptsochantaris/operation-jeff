SECTION PAGE_28
ORG 0

PUBLIC _keyboardLookup
_keyboardLookup:
    DEFB '1', '2', '3', '4', '5', '0', '9', '8', '7', '6'
    DEFB 'Q', 'W', 'E', 'R', 'T', 'P', 'O', 'I', 'U', 'Y'
    DEFB 'A', 'S', 'D', 'F', 'G',  13, 'L', 'K', 'J', 'H'
    DEFB   1, 'Z', 'X', 'C', 'V', ' ',   2, 'M', 'N', 'B'

    DS 16 ; to get to ISR address

GLOBAL mouseHandler

isr:
    push af
    push bc
    push de
    push hl
    push iy

    call mouseHandler

    pop iy
    pop hl
    pop de
    pop bc
    pop af
    
    ei
    ret
isrEnd:

SECTION PAGE_28_POSTISR
org isrEnd
