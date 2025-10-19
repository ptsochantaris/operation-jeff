SECTION PAGE_28_POSTISR

GLOBAL dmaFillValue, outLoop7, outLoop10, outLoop16, dmaHeader, dmaAudioBuf, Dsource, Dlength, Dr5, Dr1, Dr2, Dr4, Ddestination, audioPrescalar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaResetStatus
_dmaResetStatus:
    ld a, $8b ; 1000 1011 - reset status byte
    ld bc, $6b
    out (c), a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _stopDma
_stopDma:
    ld bc, $6b
    ld a, $c3
    out (c), a  ; 11000011 ; R6 reset dma
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaWaitForEnd
_dmaWaitForEnd:
    ld bc, $6b
dmaWaitForEndLoop:
    ld a, $bf ; 1011 1011 - ask for DMA controller status byte
    out (c), a
    in a, (c) ; read response: 00E1101T
    and $20 ; check "E" bit is zero
    ret z
    jp dmaWaitForEndLoop

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
    ld (Dr5), a

    pop de ; prescalar
    ld a, e
    ld (audioPrescalar), a

    pop de ; length
    ld (Dlength), de

    ex (sp), hl ; source / call address back on stack
    ld (Dsource), hl

    ld bc, $6b
    ld hl, dmaHeader ; just the header
    call outLoop7
    ld hl, dmaAudioBuf
    jp outLoop10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaMemoryToMemory
_dmaMemoryToMemory:
    pop hl ; call address
    
    pop de ; length
    ld (Dlength), de

    pop de ; destination
    ld (Ddestination), de

    ex (sp), hl ; source / call address back on stack
    ld (Dsource), hl

    ld a, $54; ; 0101 0100 ; R1 - increment, from memory, bitmask
    ld (Dr1), a
    ld a, $50; ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (Dr2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (Dr5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaMemoryToPort
_dmaMemoryToPort:
    pop hl ; call address
    
    pop de ; length
    ld (Dlength), de

    pop de ; port
    ld (Ddestination), de

    ex (sp), hl ; source / call address back on stack
    ld (Dsource), hl

    ld a, $54; ; 0101 0100 ; R1 - increment, from memory, bitmask
    ld (Dr1), a
    ld a, $68; ; 0110 1000 ; R2 - do not increment, to port, bitmask
    ld (Dr2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (Dr5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _fillWithDma
_fillWithDma:
    pop hl      ; call address
    
    pop de      ; value
    ld a, e
    ld (dmaFillValue), a
    ld de, dmaFillValue    ; Address of the fill value byte
    ld (Dsource), de    ; as the DMA source

    pop de      ; length
    ld (Dlength), de

    ex (sp), hl ; destination / call address back on stack
    ld (Ddestination), hl

    ld a, $64   ; 0110 0100 ; R1 no increment, from memory, bitmask
    ld (Dr1), a
    ld a, $50;  ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (Dr2), a
    ld a, $82   ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
    ld (Dr5), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16 ; also RETs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
