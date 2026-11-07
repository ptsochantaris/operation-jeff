SECTION PAGE_28_POSTISR

GLOBAL _copperDmaResident

; Every transfer here is programmed for the zxnDDMA of core 3.03.00 (the Makefile
; stamps that requirement into the NEX header, so the loader refuses older cores).
; Reference: docs/zxnDDMA/zxnddma.gde in the tbblue repository.
;
; Things to know before adding to this file:
;
; - HARDWARE IM2 CAN HOLD THE DMA BACK. With hardware IM2 on (NextReg $C0 bit 0,
;   which _setupInterrupts sets) and an interrupt source selected in NextRegs
;   $CC-$CE, the DMA pauses while that interrupt is pending - and under DI a
;   pending interrupt is never taken, so a transfer started there never runs and
;   the game hangs in it. _setupInterrupts zeroes $CC-$CE, so this cannot bite
;   today. If those registers are ever used (they are what lets an interrupt
;   break into a long transfer - e.g. to keep the CTC sample ISR on time during
;   an 80K blit), then no DMA may be started with interrupts disabled. Guide 2.9,
;   note 10.
;
; - Every setting survives until $C3, the new mode flags included, so every
;   program here starts with one (dmaBegin). A transfer that inherited the
;   physical or fill flag from the last one would write somewhere else entirely.
;
; - Physical addresses can't reach 16K banks 5 and 7 (8K pages 10, 11, 14, 15):
;   they live in block RAM, and a physical write lands in the SRAM behind them.
;   The ULA screen and the tilemap are in bank 5, so anything aimed at them has to
;   go through the MMU instead - fillWithDma2D does.
;
; - Each new program displaces the copper's resident transfer, so every entry
;   point clears _copperDmaResident (in dmaBegin) before it programs anything.
;
; - Transfers run in continuous mode: the CPU stops until the last byte is
;   written, so nothing here has to wait for completion - but nothing else runs
;   either, interrupts included, for the length of the transfer.
;
; - The port is decoded on A7-A0 only, so `out (c), r` works whatever is in B.
;   The code here still keeps BC = $006B, except where it says otherwise.

LAYER2_BASE_PAGE equ 18     ; as in utility.h: the first 8K page of the Layer 2 screen
LAYER2_PHYSICAL  equ $40000 + LAYER2_BASE_PAGE * $2000
LAYER2_PHYSICAL_HIGH equ LAYER2_PHYSICAL >> 16          ; bits 23:16
LAYER2_PHYSICAL_MID  equ (LAYER2_PHYSICAL >> 8) & $ff   ; bits 15:8 (bits 7:0 are 0)

    MACRO dmaOut value
    ld a, value
    out (c), a
    ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Unused - kept for reference
; PUBLIC _dmaResetStatus
; _dmaResetStatus:
;     ld a, $8b ; 1000 1011 - reset status byte
;     out ($6b), a
;     RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Unused - kept for reference
; PUBLIC _stopDma
; _stopDma:
;     ld a, $c3
;     out ($6b), a  ; 11000011 ; R6 reset dma
;     ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Unused - kept for reference
; PUBLIC _dmaWaitForEnd
; _dmaWaitForEnd:
;     ld a, $bf ; 1011 1011 - ask for DMA controller status byte
;     out ($6b), a
;     xor a ; MSB of port, set to zero
;     in a, ($6b) ; read response: 00E1101T from port $006B
;     and $20 ; check "E" bit is zero
;     ret z
;     jp _dmaWaitForEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Start a new program: invalidate the copper's resident transfer, then reset
; the controller, which also clears every zxnDDMA flag, value and stride.
; out: bc = $006B. Uses a; keeps de, hl, iy.
;
; Also public as dmaReset, for handing the controller to code that predates the
; zxnDDMA - esxDOS above all. Our programs leave physical/2D/fill mode set (they
; persist until a $C3), and anything that programs the DMA without a $C3 of its
; own would inherit them.
PUBLIC _dmaReset
_dmaReset:
dmaBegin:
    xor a
    ld (_copperDmaResident), a
    ld bc, $6b
    dmaOut $c3              ; R6 reset
    ret

; Physical address of a byte in an 8K page.
; in:  a = page, hl = its address through whichever MMU slot the page would sit
;      in (only the low 13 bits are used, so any slot will do)
; out: a = bits 23:16, hl = bits 15:0. Keeps bc, de.
physicalAddress:
    push de
    add a, 32               ; SRAM starts at physical $40000, which is page 32
    ld d, a
    ld e, 32
    mul d, e                ; de = page * 32, so page * $2000 = d:e:00
    ld a, h
    and $1f                 ; offset within the page
    or e
    ld h, a
    ld a, d
    pop de
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaRepeat
_dmaRepeat:
     ld a, $cf // R6 LOAD  - reload the resident transfer's counters (and its $D7/$DB bytes)
     out ($6b), a
     ld a, $87 // R6 ENABLE - re-run it
     out ($6b), a
     RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; void dmaPageToPort(byte page, const byte *address, word port, word length) __z88dk_callee __smallc
; Source by physical address, so `page` needn't be mapped in. `address` is where
; the data would be with `page` in its MMU slot (only its low 13 bits count);
; the transfer may run on into the pages after it.
PUBLIC _dmaPageToPort
_dmaPageToPort:
    pop iy                  ; return address
    pop de                  ; length
    pop bc                  ; port
    pop hl                  ; address
    ex (sp), hl             ; hl = page, address where it was
    ld a, l
    pop hl                  ; address
    call physicalAddress    ; a = bits 23:16, hl = bits 15:0
    push bc                 ; port, for R4
    push af
    call dmaBegin
    dmaOut $d7              ; port A bits 23:16
    pop af
    out (c), a
    dmaOut $df
    dmaOut $01              ; physical addresses
    dmaOut $7d              ; R0: A -> B, port A address and length follow
    out (c), l
    out (c), h
    out (c), e
    out (c), d
    ld hl, dmaToPortProgram
    ld b, dmaToPortProgramEnd - dmaToPortProgram
    otir                    ; leaves b = 0
    pop hl                  ; port
    push iy                 ; return address
    dmaOut $ad              ; R4: continuous, port B address follows
    out (c), l
    out (c), h
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    ret

.dmaToPortProgram:
    DB $54, $02             ; R1: memory, increment, 2-cycle timing
    DB $68, $02             ; R2: I/O, fixed, 2-cycle timing
    DB $82                  ; R5: stop at the end of the block
.dmaToPortProgramEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; void dmaCopyPhysical(byte sourcePage, const byte *sourceAddress,
;                      byte destinationPage, byte *destinationAddress, word length) __z88dk_callee __smallc
; Memory to memory by physical address, up to 64K, so neither end needs mapping
; in. Each address is where the data would be with its page in an MMU slot (only
; the low 13 bits count); a transfer may run on into the following pages.
PUBLIC _dmaCopyPhysical
_dmaCopyPhysical:
    push ix
    ld ix, 4
    add ix, sp              ; ix+0 length, +2 destination address, +4 destination page,
                            ; +6 source address, +8 source page
    call dmaBegin

    ld a, (ix+8)
    ld l, (ix+6)
    ld h, (ix+7)
    call physicalAddress    ; the source
    push af
    dmaOut $d7              ; port A bits 23:16
    pop af
    out (c), a
    dmaOut $7d              ; R0: A -> B, port A address and length follow
    out (c), l
    out (c), h
    ld a, (ix+0)
    out (c), a
    ld a, (ix+1)
    out (c), a

    ld a, (ix+4)
    ld l, (ix+2)
    ld h, (ix+3)
    call physicalAddress    ; the destination
    push af
    dmaOut $db              ; port B bits 23:16
    pop af
    out (c), a
    dmaOut $ad              ; R4: continuous, port B address follows
    out (c), l
    out (c), h

    ld hl, dmaCopyPhysicalProgram
    ld b, dmaCopyPhysicalProgramEnd - dmaCopyPhysicalProgram
    otir
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    pop ix
    pop hl                  ; return address
    ld iy, 10
    add iy, sp
    ld sp, iy               ; drop the five arguments
    jp (hl)

.dmaCopyPhysicalProgram:
    DB $54, $02             ; R1: memory, increment, 2-cycle timing
    DB $50, $02             ; R2: memory, increment, 2-cycle timing
    DB $82                  ; R5: stop at the end of the block
    DB $df, $01             ; physical addresses
.dmaCopyPhysicalProgramEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; void fillWithDma2D(word destination, word rowLength, word rows, word stride, byte value) __z88dk_callee __smallc
; Fill mode: the value is written and nothing is read, half the bus traffic of
; the fixed-source fill this used to be. `rows` runs of `rowLength` bytes,
; `stride` apart (start to start). The destination goes through the MMU, so this
; one can reach bank 5 - the ULA screen and the tilemap. fillWithDma (dma.h) is
; the one-row case.
PUBLIC _fillWithDma2D
_fillWithDma2D:
    call dmaBegin
    pop iy                  ; return address
    pop de                  ; value
    dmaOut $f7              ; fill value
    out (c), e
    pop de                  ; stride
    dmaOut $ef              ; port B stride
    out (c), e
    out (c), d
    pop de                  ; rows
    dmaOut $e7              ; number of rows
    out (c), e
    out (c), d
    pop de                  ; row length
    dmaOut $e3              ; row length
    out (c), e
    out (c), d
    pop hl                  ; destination
    push iy                 ; return address
    dmaOut $df
    dmaOut $0a              ; 2D + fill, MMU addresses
    ld de, dmaFillProgram
    ex de, hl
    ld b, dmaFillProgramEnd - dmaFillProgram
    otir
    ex de, hl
    dmaOut $ad              ; R4: continuous, port B address follows
    out (c), l
    out (c), h
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    ret

.dmaFillProgram:
    DB $05                  ; R0: A -> B (fill mode never reads port A)
    DB $14                  ; R1: memory, increment
    DB $50, $02             ; R2: memory, increment, 2-cycle timing
    DB $82                  ; R5: stop at the end of the block
.dmaFillProgramEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Whole 8K pages by physical address, as one 2D transfer of a page per row.
; WR0's block length tops out at 64K; the 2D counters don't, so ten pages (the
; whole 320x256 screen) go in one go, and the address carries into bits 23:16 by
; itself.

; void dmaFillPages(byte page, byte count, byte value) __z88dk_callee __smallc
PUBLIC _dmaFillPages
_dmaFillPages:
    pop iy                  ; return address
    pop de                  ; value
    pop hl
    ld d, l                 ; d = page count, e = value
    ex (sp), iy             ; iy = first page, return address back on the stack
    call dmaBegin
    dmaOut $f7              ; fill value
    out (c), e
    dmaOut $05              ; R0: A -> B (fill mode never reads port A)
    ld a, iyl
    ld e, $0b               ; physical + 2D + fill
    jr dmaPagesTo

; void dmaCopyPages(byte sourcePage, byte destinationPage, byte count) __z88dk_callee __smallc
PUBLIC _dmaCopyPages
_dmaCopyPages:
    pop iy                  ; return address
    pop hl
    ld d, l                 ; d = page count
    pop hl                  ; destination page
    ex (sp), iy             ; iy = source page, return address back on the stack
    push hl
    call dmaBegin
    ld a, iyl
    ld hl, 0
    call physicalAddress
    push af
    dmaOut $d7              ; port A bits 23:16
    pop af
    out (c), a
    dmaOut $1d              ; R0: A -> B, port A address follows
    out (c), l
    out (c), h
    pop hl
    ld a, l                 ; destination page
    ld e, $03               ; physical + 2D
    ; fall through

; in: a = first destination page, d = page count, e = $DF mode flags, bc = $006B
.dmaPagesTo:
    ld hl, 0
    call physicalAddress
    push af
    dmaOut $db              ; port B bits 23:16
    pop af
    out (c), a
    dmaOut $ad              ; R4: continuous, port B address follows
    out (c), l
    out (c), h
    dmaOut $e7              ; number of rows: one per page
    out (c), d
    xor a
    out (c), a
    ld hl, dmaPagesProgram
    ld b, dmaPagesProgramEnd - dmaPagesProgram
    otir
    dmaOut $df
    out (c), e              ; mode flags
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    ret

.dmaPagesProgram:
    DB $e3, $00, $20        ; row length: one 8K page
    DB $eb, $00, $20        ; port A stride: on to the next page
    DB $ef, $00, $20        ; port B stride: on to the next page
    DB $54, $02             ; R1: memory, increment, 2-cycle timing
    DB $50, $02             ; R2: memory, increment, 2-cycle timing
    DB $82                  ; R5: stop at the end of the block
.dmaPagesProgramEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; void dmaLayer2Copy(byte page, word offset, word x, word y, word columns, word rows, byte toScreen) __z88dk_callee __smallc
;
; Copies a columns x rows rectangle of the Layer 2 screen to or from a stash at
; `offset` in 8K page `page`, packed one screen column after another (`rows`
; bytes each). Both ends go by physical address, so neither needs mapping in.
;
; The screen end is worked out here instead of with the X,Y form of $DF, which
; only ever sets port B. Every transfer here runs A to B, so when the screen is
; the source it has to be port A. In 320x256 the address is just
; base + x * 256 + y, and a screen column is one 2D row.
PUBLIC _dmaLayer2Copy
_dmaLayer2Copy:
    push ix
    ld ix, 4
    add ix, sp              ; ix+0 toScreen, +2 rows, +4 columns, +6 y, +8 x, +10 offset, +12 page

    call dmaBegin
    dmaOut $e3              ; row length: one screen column of the rectangle
    ld a, (ix+2)
    out (c), a
    ld a, (ix+3)
    out (c), a
    dmaOut $e7              ; number of rows: its width
    ld a, (ix+4)
    out (c), a
    ld a, (ix+5)
    out (c), a
    ld hl, dmaLayer2CopyProgram
    ld b, dmaLayer2CopyProgramEnd - dmaLayer2CopyProgram
    otir

    ld a, (ix+12)
    ld l, (ix+10)
    ld h, (ix+11)
    call physicalAddress    ; the stash
    ld e, a
    ld a, (ix+2)
    ld iyl, a
    ld a, (ix+3)
    ld iyh, a               ; its stride: one packed column

    bit 0, (ix+0)
    jr z, dmaLayer2CopyFromScreen

    ld a, $d7
    ld d, $1d
    call dmaPort            ; port A: the stash
    call dmaLayer2Address
    ld a, $db
    ld d, $ad
    call dmaPort            ; port B: the screen
    jr dmaLayer2CopyGo

.dmaLayer2CopyFromScreen:
    ld a, $db
    ld d, $ad
    call dmaPort            ; port B: the stash
    call dmaLayer2Address
    ld a, $d7
    ld d, $1d
    call dmaPort            ; port A: the screen

.dmaLayer2CopyGo:
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    pop ix
    pop hl                  ; return address
    ld iy, 14
    add iy, sp
    ld sp, iy               ; drop the seven arguments
    jp (hl)

.dmaLayer2CopyProgram:
    DB $54, $02             ; R1: memory, increment, 2-cycle timing
    DB $50, $02             ; R2: memory, increment, 2-cycle timing
    DB $82                  ; R5: stop at the end of the block
    DB $df, $03             ; physical + 2D
.dmaLayer2CopyProgramEnd:

; e:hl = physical address of (x, y) from the dmaLayer2Copy frame, iy = 256 (the
; stride from one screen column to the next)
.dmaLayer2Address:
    ld l, (ix+6)            ; y
    ld a, (ix+8)
    add a, LAYER2_PHYSICAL_MID
    ld h, a
    ld a, (ix+9)
    adc a, LAYER2_PHYSICAL_HIGH
    ld e, a
    ld iy, 256
    ret

; One end of a physical 2D transfer.
; in: a = $D7 (port A) or $DB (port B), d = that port's address command ($1D:
;     R0, A -> B, port A address follows; $AD: R4, continuous, port B address
;     follows), e:hl = physical address, iy = stride, bc = $006B
.dmaPort:
    out (c), a              ; bits 23:16 command
    out (c), e
    add a, $14              ; $D7 -> $EB, $DB -> $EF: the same port's stride
    out (c), a
    ld a, iyl
    out (c), a
    ld a, iyh
    out (c), a
    out (c), d              ; address command
    out (c), l
    out (c), h
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Box fill for layer2fill, which jumps here for boxes big enough to repay the
; ~450 T of programming (see the threshold there). The X,Y form of $DF works the
; screen address out from NextReg $12 and $70, so this needs no page arithmetic
; and doesn't care which page boundaries the box crosses. In 320x256 a 2D row
; runs down a screen column: row length = height, number of rows = width.
;
; in: iyh = colour, b = height, c = y, de = width, hl = x (all non-zero, on screen)
;     and the caller's return address on the stack
PUBLIC layer2fillDma
layer2fillDma:
    ld a, c
    ld iyl, a               ; y
    push bc                 ; the height rides in the high byte
    call dmaBegin
    dmaOut $e3              ; row length: the height
    pop af                  ; a = the height
    out (c), a
    xor a
    out (c), a
    dmaOut $e7              ; number of rows: the width
    out (c), e
    out (c), d
    dmaOut $f7              ; fill value: the colour
    ld a, iyh
    out (c), a
    push hl
    ld hl, dmaBoxProgram
    ld b, dmaBoxProgramEnd - dmaBoxProgram
    otir
    pop hl
    dmaOut $df              ; must follow R4, which would otherwise overwrite the address
    dmaOut $1b              ; physical + 2D + fill + Layer 2 X,Y
    out (c), l
    out (c), h              ; x
    ld a, iyl
    out (c), a              ; y
    dmaOut $cf              ; R6 load
    dmaOut $87              ; R6 enable
    ret

.dmaBoxProgram:
    DB $05                  ; R0: A -> B (fill mode never reads port A)
    DB $14                  ; R1: memory, increment
    DB $50, $02             ; R2: memory, increment, 2-cycle timing
    DB $a1                  ; R4: continuous, no address - the X,Y supplies it
    DB $82                  ; R5: stop at the end of the block
.dmaBoxProgramEnd:
