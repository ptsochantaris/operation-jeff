SECTION code_compiler

PUBLIC _aySetAmplitude
_aySetAmplitude:
    pop hl ; address
    pop de ; volume: 0 - 15 (16 = use envelope)
    ex (sp), hl ; channel on l, address back on stack

    ld a, l
    add a, 8 ; reg
    ld bc, $fffd
    out(c), a ; reg index
    ld a, e
    ld b, $bf
    out(c), a ; volume
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
    out(c), a

    ld a, 1

    ld b, l ; channel
aySetMixerShiftLoop:
    RLCA
    djnz aySetMixerShiftLoop

    ld (aySetMixerToneNo+1), a
    cpl
    ld (aySetMixerToneYes+1), a
    RLCA
    RLCA
    RLCA
    ld (aySetMixerNoiseYes+1), a
    cpl
    ld (aySetMixerNoiseNo+1), a

    ld bc, $fffd
    in a, (c) ; a = existing
    pop bc
    ld b, a ; b = existing

    ld a, c ; tone set?
    or a
    ld a, b ; a = existing
    jp z, aySetMixerToneNo
aySetMixerToneYes:
    and 0
    jp aySetMixerToneDone
aySetMixerToneNo:
    or 0
aySetMixerToneDone:
    ld b, a; b = existing

    ld a, e ; noise set?
    or a
    ld a, b ; a = existing
    jp z, aySetMixerNoiseNo
aySetMixerNoiseYes:
    and 0
    jp aySetMixerNoiseDone
aySetMixerNoiseNo:
    or 0
aySetMixerNoiseDone:
    ld bc, $bffd
    out(c), a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetEnvelope
_aySetEnvelope:
    pop hl ; address
    pop de ; duration: 0 - 65535
    ex (sp), hl ; type: 0 - 15

    ld bc, $fffd
    ld a, 11
    out (c), a

    ld b, $bf
    ld a, e ; duration low
    out(c), a

    ld b, $ff
    ld a, 12
    out (c), a

    ld b, $bf
    ld a, d ; duration high
    out(c), a

    ld b, $ff
    ld a, 13
    out (c), a

    ld b, $bf
    ld a, l ; type
    out(c), a

    ;0       \__________     single decay then off
    ;4       /|_________     single attack then off
    ;8       \|\|\|\|\|\     repeated decay
    ;10      \/\/\/\/\/\     repeated decay-attack
    ;          _________
    ;11      \|              single decay then hold
    ;12      /|/|/|/|/|/     repeated attack
    ;         __________
    ;13      /               single attack then hold
    ;14      /\/\/\/\/\/     repeated attack-decay
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
    out(c), a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _ayChipSelect ; L: chip 0 - 2
_ayChipSelect:
    ld a, 3 ; first AY on both channels
    sub l
    or $fc
    ld bc, $fffd
    out(c), a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _aySetPitch
_aySetPitch:
    pop hl ; address
    pop de ; pitch: 0 - 4095
    ex (sp), hl ; channel on l, address back on stack
    sla l ; reg1 = channel x 2

    ld a, l
    ld bc, $fffd
    out(c), a ; reg1 index
    ld a, e
    ld b, $bf
    out(c), a ; pitch low byte

    inc l ; next reg
    ld a, l
    ld b, $ff
    out(c), a ; reg 2 index
    ld a, d
    and $F
    ld b, $bf
    out(c), a ; pitch high byte
    RET
