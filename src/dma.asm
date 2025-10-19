SECTION code_compiler

GLOBAL outLoop16, outLoop11, outLoop10, outLoop7, outLoop5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dma setup - 7 bytes

dmaHeader:          DB $c3      ; 11000011 ; R6 reset dma
                    DB $7e      ; 01111101 ; R0-Transfer mode, A -> B, will provide address and length
.Dsource:           DW 0        ; source address 
.Dlength:           DW 0        ; transfer length
.Dr5:               DB $82      ; 1000 0010 ; R5-Stop on end of block, RDY active LOW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transfer payload - 9 bytes

.Dr1:               DB 0        ; R1 - from config
                    DB 2        ; 0000 0010 - 2t timing for R1
.Dr2:               DB 0        ; R2 - to config
                    DB 2        ; 0000 0010 - 2t timing for R2
.Dr4:               DB $ad      ; 1010 1101 ; R4 Continuous mode, will provide destination
.Ddestination:      DW 0        ; destination post/address
                    DB $cf      ; R6 load
                    DB $87      ; R6 enable DMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stream payload (i.e. audio) - 10 bytes

dmaAudioBuf:        DB $54      ; 0101 0100 ; R1 increment, from memory
                    DB $02      ; 0000 0010 ; no prescalar, 2t cycle
                    DB $68      ; 0110 1000 ; R2 do not increment, to port
                    DB $22      ; 0010 0010 ; want prescalar, use 2t cycle
.audioPrescalar:    DB $37      ; $37 is supposed to be ~16 Khz prescalar, but isn't
                    DB $cd      ; 1100 1101 ; R4 burst mode, dest value follows
                    DB $df      ; Dest covox port H
                    DB $ff      ; Dest covox port L
                    DB $cf      ; R6 load
                    DB $87      ; R6 enable DMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _dmaResetStatus
_dmaResetStatus:
    ld a, $8b ; 1000 1011 - reset status byte
    ld bc, $6b
    out (c), a
    RET

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
    ld (fillValue), a
    ld de, fillValue    ; Address of the fill value byte
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

.fillValue:
    DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _fillWithDmaRepeat
_fillWithDmaRepeat:
    pop hl      ; call address

    pop de      ; step
    ld (fillWithDmaRepeatStep+2), de

    pop de      ; times

    pop bc      ; value
    ld a, c
    ld (fillValue), a
    ld bc, fillValue    ; Address of the fill value byte
    ld (Dsource), bc    ; as the DMA source

    pop bc      ; length
    ld (Dlength), bc

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
    call outLoop16

.fillWithDmaRepeatLoop:
    dec de
    ld a, e
    or d
    ret z

    ld hl, (Ddestination)
.fillWithDmaRepeatStep:    
    add hl, 0 ; placeholder for step
    ld (Ddestination), hl ; increment destination

    ld hl, Dr4 ; rewind back to Dr4
    call outLoop5 ; write last 5 bytes to DMA port, from Dr4 onwards
    jp fillWithDmaRepeatLoop

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

PUBLIC _stopDma
_stopDma:
    ld bc, $6b
    ld a, $c3
    out (c), a  ; 11000011 ; R6 reset dma
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
