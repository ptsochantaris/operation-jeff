SECTION PAGE_28_POSTISR

GLOBAL dmaFillValue, outLoop7, outLoop10, outLoop16
GLOBAL dmaAudioBuf, dmaSource, dmaLength, DmaR5, dmaR1, dmaR2, dmaR5, dmaDestination, dmaPrescalar, dmaHeader

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaResetStatus
_dmaResetStatus:
    ld a, $8b ; 1000 1011 - reset status byte
    out ($6b), a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _stopDma
_stopDma:
    ld a, $c3
    out ($6b), a  ; 11000011 ; R6 reset dma
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaWaitForEnd
_dmaWaitForEnd:
    ld a, $bf ; 1011 1011 - ask for DMA controller status byte
    out ($6b), a
    xor a ; MSB of port, set to zero
    in a, ($6b) ; read response: 00E1101T from port $006B
    and $20 ; check "E" bit is zero
    ret z
    jp _dmaWaitForEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _playWithDma
_playWithDma:
    pop hl ; address

    pop de ; loop flag
    ld a, e
    or a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    jr z, playWithDmaNonLoop
    add $20     ; loop 1010 0010 ; R5-Loop on end of block, RDY active LOW
.playWithDmaNonLoop:
    ld (dmaR5), a

    pop de ; prescalar
    ld a, e
    ld (dmaPrescalar), a

    pop de ; length
    ld (dmaLength), de

    ex (sp), hl ; source / call address back on stack
    ld (dmaSource), hl

    ld bc, $6b
    ld hl, dmaHeader ; just the header
    call outLoop7
    ld hl, dmaAudioBuf
    jp outLoop10 ; also RETs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaMemoryToMemory
_dmaMemoryToMemory:
    pop hl ; call address
    
    pop de ; length
    ld (dmaLength), de

    pop de ; destination
    ld (dmaDestination), de

    ex (sp), hl ; source / call address back on stack
    ld (dmaSource), hl

    ld a, $54; ; 0101 0100 ; R1 - increment, from memory, bitmask
    ld (dmaR1), a
    ld a, $50; ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (dmaR2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (dmaR5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16 ; also RETs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaMemoryToPort
_dmaMemoryToPort:
    pop hl ; call address
    
    pop de ; length
    ld (dmaLength), de

    pop de ; port
    ld (dmaDestination), de

    ex (sp), hl ; source / call address back on stack
    ld (dmaSource), hl

    ld a, $54; ; 0101 0100 ; R1 - increment, from memory, bitmask
    ld (dmaR1), a
    ld a, $68; ; 0110 1000 ; R2 - do not increment, to port, bitmask
    ld (dmaR2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (dmaR5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16 ; also RETs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _fillWithDma
_fillWithDma:
    pop hl      ; call address
    
    pop de      ; value
    ld a, e
    ld (dmaFillValue), a
    ld de, dmaFillValue    ; Address of the fill value byte
    ld (dmaSource), de    ; as the DMA source

    pop de      ; length
    ld (dmaLength), de

    ex (sp), hl ; destination / call address back on stack
    ld (dmaDestination), hl

    ld a, $64   ; 0110 0100 ; R1 no increment, from memory, bitmask
    ld (dmaR1), a
    ld a, $50;  ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (dmaR2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (dmaR5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16 ; also RETs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
