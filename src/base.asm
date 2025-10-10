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

GLOBAL inputHandler

isr:
    push af
    push bc
    push de
    push hl

    call inputHandler

    pop hl
    pop de
    pop bc
    pop af
    
    ei
    ret
isrEnd:

SECTION PAGE_28_POSTISR
org isrEnd

PUBLIC _bombRadii1, _bombRadii2
_bombRadii1: DW 7, 8, 9, 10, 9, 8, 8, 8
_bombRadii2: DW 14, 16, 18, 20, 18, 16, 16, 16

PUBLIC outLoop16, outLoop11, outLoop10, outLoop7, outLoop5

outLoop16:
    outinb
    outinb
    outinb
    outinb
    outinb
outLoop11:
    outinb
outLoop10:
    outinb
    outinb
    outinb
outLoop7:
    outinb
    outinb
outLoop5:
    outinb
    outinb
    outinb
    outinb
    outinb
    ret
