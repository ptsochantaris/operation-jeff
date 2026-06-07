SECTION PAGE_28
ORG 0

; INVARIANT: base.asm must be the ONLY thing in plain PAGE_28, so it lands at
; offset 0 and the IM2 vector table below sits at absolute 0x0000 (I=0 in
; _setupInterrupts points the CPU here). Everything else - C const data
; (--constseg PAGE_28_POSTISR) and the other -ro.asm modules - goes in
; PAGE_28_POSTISR. Do NOT add a bare `SECTION PAGE_28` or `--constseg PAGE_28`
; anywhere else: it may link ahead of this file, push the table off 0x0000, and
; the game will hang on the first interrupt (vectors read from garbage).

GLOBAL ctcAudioHandler, inputHandler

    DW im2Ignore       ; 0  line
    DW im2Ignore       ; 1  UART0 Rx
    DW im2Ignore       ; 2  UART1 Rx
    DW ctcAudioHandler ; 3  CTC channel 0 (audio)
    DW im2Ignore       ; 4  CTC channel 1
    DW im2Ignore       ; 5  CTC channel 2
    DW im2Ignore       ; 6  CTC channel 3
    DW im2Ignore       ; 7  CTC channel 4
    DW im2Ignore       ; 8  CTC channel 5
    DW im2Ignore       ; 9  CTC channel 6
    DW im2Ignore       ; 10 CTC channel 7
    DW inputHandler    ; 11 ULA frame
    DW im2Ignore       ; 12 UART0 Tx
    DW im2Ignore       ; 13 UART1 Tx
    DW im2Ignore       ; 14 spare
    DW im2Ignore       ; 15 spare

im2Ignore:
    ei
    reti

PUBLIC keyboardLookup
keyboardLookup:
    DB '1', '2', '3', '4', '5', '0', '9', '8', '7', '6'
    DB 'Q', 'W', 'E', 'R', 'T', 'P', 'O', 'I', 'U', 'Y'
    DB 'A', 'S', 'D', 'F', 'G',  13, 'L', 'K', 'J', 'H'
    DB   1, 'Z', 'X', 'C', 'V', ' ',   2, 'M', 'N', 'B'
    DB   0,   0,   0,   0,   0,   0,   0

PUBLIC keyboardPorts
keyboardPorts: 
    DB $f7, $ef, $fb, $df, $fd, $bf, $fe, $7f, 0

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

preambleEnd:

SECTION PAGE_28_POSTISR
org preambleEnd
