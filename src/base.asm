SECTION PAGE_28
ORG 0

PUBLIC keyboardLookup
keyboardLookup:
    DB '1', '2', '3', '4', '5', '0', '9', '8', '7', '6'
    DB 'Q', 'W', 'E', 'R', 'T', 'P', 'O', 'I', 'U', 'Y'
    DB 'A', 'S', 'D', 'F', 'G',  13, 'L', 'K', 'J', 'H'
    DB   1, 'Z', 'X', 'C', 'V', ' ',   2, 'M', 'N', 'B'
    DB 0

    DS 15

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
