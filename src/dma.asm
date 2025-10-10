SECTION code_compiler

GLOBAL outLoop16, outLoop11, outLoop10, outLoop7, outLoop5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dmaHeader: ; 7 bytes
.Dr6a:              DB $c3      ; 11000011 ; R6 reset dma
.Dr0:               DB $7e      ; 01111101 ; R0-Transfer mode, A -> B, will provide address and length
.Dsource:           DW 0        ; source address 
.Dlength:           DW 0        ; transfer length
.Dr5:               DB $82      ; 1000 0010 ; R5-Stop on end of block, RDY active LOW
; dma payload - 9 bytes
.Dr1:               DB 0        ; R1 - from config
.Dr1t:              DB 2        ; 0000 0010 - 2t timing for R1
.Dr2:               DB 0        ; R2 - to config
.Dr2t:              DB 2        ; 0000 0010 - 2t timing for R2
.Dr4:               DB $ad      ; 1010 1101 ; R4 Continuous mode, will provide destination
.Ddestination:      DW 0        ; destination post/address,
.Dr6b:              DB $cf, $87 ; (R6 load, R6 enable DMA)

dmaAudioBuf:        DB $54      ; 0101 0100 ; R1 increment, from memory
                    DB $02      ; 0000 0010 ; no prescalar, 2t cycle
                    DB $68      ; 0110 1000 ; R2 do not increment, to port
                    DB $22      ; 0010 0010 ; want prescalar, use 2t cycle
.audioPrescalar:    DB $37      ; $37 is supposed to be ~16 Khz prescalar, but isn't
                    DB $cd      ; 1100 1101 ; R4 burst mode, dest value follows
                    DB $df, $ff ; Dest covox port L, H
                    DB $cf, $87 ; (R6 load, R6 enable DMA)

PUBLIC _dmaResetStatus
_dmaResetStatus:
    ld a, $8b ; 1000 1011 - reset status byte
    ld bc, $6b
    out (c), a
    RET

PUBLIC _playWithDma
_playWithDma:
    pop hl ; address

    pop de ; loop / prescalar

    ld a, d ; loop
    or a
    ld a, $82
    jr z, playWithDmaNonLoop
    add $20 ; loop
.playWithDmaNonLoop:
    ld (Dr5), a

    ld a, e ; prescalar
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

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16

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

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16

PUBLIC _fillWithDma
_fillWithDma:
    pop hl      ; call address
    
    pop de      ; value
    ld a, e
    ld (fillValue), a
    ld de, fillValue
    ld (Dsource), de

    pop de      ; length
    ld (Dlength), de

    ex (sp), hl ; destination / call address back on stack
    ld (Ddestination), hl

    ld a, 0x64   ; 0110 0100 ; R1 no increment, from memory, bitmask
    ld (Dr1), a
    ld a, $50;  ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (Dr2), a

    ld bc, $6b
    ld hl, dmaHeader
    jp outLoop16

.fillValue:
    DB 0

PUBLIC _fillWithDmaRepeat
_fillWithDmaRepeat:
    pop hl      ; call address

    pop de      ; step
    ld (fillWithDmaRepeatStep+1), de

    pop de      ; times
    ld a, e
    ld (fillWithDmaRepeatTimes+1), a

    pop de      ; value
    ld a, e
    ld (fillValue), a
    ld de, fillValue
    ld (Dsource), de

    pop de      ; length
    ld (Dlength), de

    ex (sp), hl ; destination / call address back on stack
    ld (Ddestination), hl

    ld a, 0x64   ; 0110 0100 ; R1 no increment, from memory, bitmask
    ld (Dr1), a
    ld a, $50;  ; 0101 0000 ; R2 - increment, to memory, bitmask
    ld (Dr2), a

    ld bc, $6b  ; write first 11 bytes to DMA port
    ld hl, dmaHeader
.fillWithDmaRepeatTimes:
    ld a, 0
    call outLoop11

.fillWithDmaRepeatLoop:
    call outLoop5

.fillWithDmaRepeatStep:
    ld de, 0     ; placeholder
    ld hl, (Ddestination)
    add hl, de
    ld (Ddestination), hl
    dec a
    ret z
    ld hl, Dr4 ; 5 last bytes of dma program
    jp fillWithDmaRepeatLoop

PUBLIC _dmaWaitForEnd
_dmaWaitForEnd:
    ld bc, $6b
dmaWaitForEndLoop:
    ld a, $bf // 1011 1011 - read status byte
    out (c), a
    in a, (c) // 00E1101T
    and $10
    ret z
    jp dmaWaitForEndLoop

PUBLIC _stopDma
_stopDma:
    ld bc, $6b
    ld a, $c3
    out (c), a  ; 11000011 ; R6 reset dma
    ret
