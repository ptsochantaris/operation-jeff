SECTION code_compiler

GLOBAL outLoop16, outLoop11, outLoop10, outLoop7, outLoop5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dma setup - 7 bytes

PUBLIC dmaHeader, Dsource, Dlength, Dr5

dmaHeader:          DB $c3      ; 11000011 ; R6 reset dma
                    DB $7e      ; 01111101 ; R0-Transfer mode, A -> B, will provide address and length
Dsource:            DW 0        ; source address 
Dlength:            DW 0        ; transfer length
Dr5:                DB $82      ; 1000 0010 ; R5-Stop on end of block, RDY active LOW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transfer payload - 9 bytes

PUBLIC Dr1, Dr2, Dr4, Ddestination

Dr1:                DB 0        ; R1 - from config
                    DB 2        ; 0000 0010 - 2t timing for R1
Dr2:                DB 0        ; R2 - to config
                    DB 2        ; 0000 0010 - 2t timing for R2
Dr4:                DB $ad      ; 1010 1101 ; R4 Continuous mode, will provide destination
Ddestination:       DW 0        ; destination post/address
                    DB $cf      ; R6 load
                    DB $87      ; R6 enable DMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stream payload (i.e. audio) - 10 bytes

PUBLIC dmaAudioBuf, audioPrescalar

dmaAudioBuf:        DB $54      ; 0101 0100 ; R1 increment, from memory
                    DB $02      ; 0000 0010 ; no prescalar, 2t cycle
                    DB $68      ; 0110 1000 ; R2 do not increment, to port
                    DB $22      ; 0010 0010 ; want prescalar, use 2t cycle
audioPrescalar:     DB $37      ; $37 is supposed to be ~16 Khz prescalar, but isn't
                    DB $cd      ; 1100 1101 ; R4 burst mode, dest value follows
                    DB $df      ; Dest covox port H
                    DB $ff      ; Dest covox port L
                    DB $cf      ; R6 load
                    DB $87      ; R6 enable DMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC dmaFillValue
dmaFillValue:       DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _fillWithDmaRepeat
_fillWithDmaRepeat:
    pop hl      ; call address

    pop de      ; step
    ld (fillWithDmaRepeatStep+2), de

    pop de      ; times

    pop bc      ; value
    ld a, c
    ld (dmaFillValue), a
    ld bc, dmaFillValue    ; Address of the fill value byte
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
