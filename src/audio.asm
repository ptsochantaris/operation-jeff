SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetAmplitude
_aySetAmplitude:
    pop hl ; address
    pop de ; volume: 0 - 15 (16 = use envelope)
    ex (sp), hl ; channel on l, address back on stack

    ld a, l
    add a, 8 ; reg
    ld bc, $fffd
    out (c), a ; reg index
    ld b, $bf
    out (c), e ; volume
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetMixer
_aySetMixer:
    pop hl ; address
    pop de ; noise
    pop bc ; tone
    ex (sp), hl ; channel on L, address back on stack

    push bc
    ld a, 7
    ld bc, $fffd
    out (c), a ; b = current AY7 register

    ld a, l ; channel number in L
    or a
    jp nz, ayChannel2
    ld d, 1 ; d = 0000 0001
    jp ayChannelDone
.ayChannel2:
    dec a
    jp nz, ayChannel3
    ld d, 2 ; d = 0000 0010
    jp ayChannelDone
.ayChannel3:
    ld d, 4 ; d = 0000 0100    
.ayChannelDone

    ld bc, $fffd
    in a, (c) ; a = existing
    pop bc ; c = tone parameter
    ld b, a ; b = existing

    ; tone

    ld a, c ; tone set?
    or a
    jp nz, aySetMixerToneYes

    ; no tone
    ld a, b ; a = existing
    or d ; set channel bit (d = 1 << channel)
    jp aySetMixerToneDone

.aySetMixerToneYes:
    ld a, d ; a = 1 << channel
    cpl ; a = ^(1 << channel)
    and b ; cleared channel bit

.aySetMixerToneDone:
    ld b, a ; b = updated 0000 0TTT (one of T is now set or cleared)

    ; move 3 places up and do the same for the noise flag
    ld a, d ; a = 1 << channel
    add a
    add a
    add a
    ld d, a ; d = 1 << (channel + 3)

    ; noise

    ld a, e ; noise set?
    or a
    jp nz, aySetMixerNoiseYes

    ; no noise
    ld a, b ; a = existing (0000 0TTT)
    or d ; set channel+3 bit (d = (1 << channel + 3))
    jp aySetMixerNoiseDone

.aySetMixerNoiseYes:
    ld a, d ; a = (1 << channel + 3)
    cpl ; invert
    and b ; cleared channel+3 bit

.aySetMixerNoiseDone:
    ld bc, $bffd
    out (c), a ; a = updated 00NN NTTT (one of N is now set or cleared)
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0       \__________     single decay then off
; 4       /|_________     single attack then off
; 8       \|\|\|\|\|\     repeated decay
; 10      \/\/\/\/\/\     repeated decay-attack
;           _________
; 11      \|              single decay then hold
; 12      /|/|/|/|/|/     repeated attack
;          __________
; 13      /               single attack then hold
; 14      /\/\/\/\/\/     repeated attack-decay

PUBLIC _aySetEnvelope
_aySetEnvelope:
    pop hl ; address
    pop de ; duration: 0 - 65535
    ex (sp), hl ; type: 0 - 14

    ; ay register 11
    ld bc, $fffd
    ld a, 11
    out (c), a

    ld b, $bf
    out (c), e ; duration low

    ; ay register 12
    ld b, $ff
    ld a, 12
    out (c), a

    ld b, $bf
    out (c), d ; duration high

    ; ay register 13
    ld b, $ff
    ld a, 13
    out (c), a

    ld b, $bf
    out (c), l ; type

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetNoise ; L: speed 0 - 31
_aySetNoise:
    ld bc, $fffd
    ld a, 6
    out (c), a

    ld b, $bf
    ld a, l
    and $1f
    out (c), a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _ayChipSelect ; L: chip 0 - 2
_ayChipSelect:
    ; L = chip (0-2)  -> 1PQ1 11XX (P = left on, Q = right on)
    ; 0000 0000 (AY1) -> 1111 1111 (XX = 3)
    ; 0000 0001 (AY2) -> 1111 1110 (XX = 2)
    ; 0000 0002 (AY3) -> 1111 1101 (XX = 1)

    ld a, l
    cpl

    ld bc, $fffd
    out (c), a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetPitch
_aySetPitch:
    pop hl ; address
    pop de ; pitch: 0 - 4095
    ex (sp), hl ; channel on l, address back on stack

    sla l ; reg1 = channel x 2

    ld bc, $fffd
    out (c), l ; reg1 index

    ld b, $bf
    out (c), e ; pitch low byte


    inc l ; reg 2
    ld b, $ff
    out (c), l ; reg 2 index

    ld a, d
    and $F
    ld b, $bf
    out (c), a ; pitch high byte
    RET
