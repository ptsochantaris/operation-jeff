SECTION PAGE_28_POSTISR

GLOBAL _paletteBuffer, font_data, setPaletteCommitRed, setPaletteCommitGreen, setPaletteCommit, layer2Char
GLOBAL layer2CharSlow, layer2CharFast, selectLayer2PageInternal
GLOBAL layer2PlotSliceSlowInk, layer2PlotSliceFastInk, selectPageForXInDeAndSetupH, layer2CharSideways, layer2PlotSliceSidewaysInk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _selectLayer2Page
_selectLayer2Page:
    ld a, l
    jp selectLayer2PageInternal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2Plot
_layer2Plot:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ex af, af'      ; stash colour

    pop HL          ; y
    pop DE          ; x
    push bc         ; put return back on stack

    call selectPageForXInDeAndSetupH

    ex af, af'      ; unstash colour
    ld (hl), a      ; set (hl) to colour value
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setPaletteCeiling
_setPaletteCeiling:
    pop hl      ; address
    pop bc      ; ceiling in C
    ex (sp), hl ; colour count in HL (2 bytes per colour), place return address back

    ld de, _paletteBuffer

    nextreg 64, 0 ; REG_PALETTE_INDEX

    ld b, l ; 8 bit loop, we keep H for later
    
.setPaletteCeilingLoop:
    ld h, (de)
    inc de

    ld a, h     ; RRRGGGBB
    rlca
    rlca
    rlca        ; GGGBBRRR
    and 7       ; 00000RRR

    cp c
    jr c, setPaletteCeilingRedBelowCeiling
    ld a, c
.setPaletteCeilingRedBelowCeiling:
    ld (setPaletteCommitRed+1), a

    ld a, h     ; RRRGGGBB
    rrca
    rrca        ; BBRRRGGG
    and 7       ; 00000GGG

    cp c
    jr c, setPaletteCeilingGreenBelowCeiling
    ld a, c
.setPaletteCeilingGreenBelowCeiling:
    ld (setPaletteCommitGreen+1), a

    ld a, h     ; RRRGGGBB
    rlca        ; RRGGGBBR
    and 6       ; 00000BB0
    ld h, a

    ld a, (de)  ; XXXXXXXB
    inc de
    and 1       ; 0000000B
    or h        ; 00000BBB

    cp c
    jr c, setPaletteCeilingBlueBelowCeiling
    ld a, c
.setPaletteCeilingBlueBelowCeiling:

    call setPaletteCommit
    djnz setPaletteCeilingLoop

    halt
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setPaletteFloor
_setPaletteFloor:
    pop hl      ; address
    pop bc      ; floor in C
    ex (sp), hl ; colour count in HL (2 bytes per colour), address back on stack

    ld de, _paletteBuffer

    nextreg 64, 0 ; REG_PALETTE_INDEX

    ld b, l ; 8 bit loop, we keep H for later
    
.setPaletteFloorLoop:
    ld h, (de)
    inc de

    ld a, h     ; RRRGGGBB
    rlca
    rlca
    rlca        ; GGGBBRRR
    and 7       ; 00000RRR

    cp c
    jr nc, setPaletteFloorRedAboveFloor
    ld a, c
.setPaletteFloorRedAboveFloor:
    ld (setPaletteCommitRed+1), a

    ld a, h     ; RRRGGGBB
    rrca
    rrca        ; BBRRRGGG
    and 7       ; 00000GGG

    cp c
    jr nc, setPaletteFloorGreenAboveFloor
    ld a, c
.setPaletteFloorGreenAboveFloor:
    ld (setPaletteCommitGreen+1), a

    ld a, h     ; RRRGGGBB
    rlca        ; RRGGGBBR
    and 6       ; 00000BB0
    ld h, a

    ld a, (de)  ; XXXXXXXB
    inc de
    and 1       ; 0000000B
    or h        ; 00000BBB

    cp c
    jr nc, setPaletteFloorBlueAboveFloor
    ld a, c
.setPaletteFloorBlueAboveFloor:

    call setPaletteCommit
    djnz setPaletteFloorLoop

    halt
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _printAttributes
_printAttributes:
    pop af          ; return address

    pop HL          ; y
    ld h, 32        ; will be using as a constant

    pop DE          ; x
    add de, $77E0   ; ula attributes: 0x6000 + 0x1800 (see tilemap.h) = 0x7800, - 32 (one row)

    exx
    pop hl          ; address of first char in HL'
    push af         ; put return back on stack

.printAttributesLoop:
    ld a, (hl) ; actually HL'
    exx
    sub h ; index = ascii - 32 (using H since it is 32 for performance)
    ret c ; exit if char is below 32

    ; put first slice of font in IY, offset from font_data
    ld bc, font_data
    ; offset is a * 6, split out for performance
    rla
    add bc, a   ; bc += (a * 2)
    rla
    add bc, a   ; bc += (a * 4)

    push de
    push hl
    call ulaAttributeChar
    pop hl
    pop de

    add de, 4 ; move X to the right
    exx
    inc hl ; next char in HL'
    jp printAttributesLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print
_print:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2PlotSliceSlowInk+1), a
    ld (layer2PlotSliceFastInk+1), a

    pop HL          ; y
    pop DE          ; x

    exx
    pop hl          ; address of first char in HL'
    push iy         ; put return back on stack

.printLoop:
    ld a, (hl) ; read from HL'
    exx
    sub 32 ; index = ascii - 32
    ret c ; exit if char is below 32

    ; put first slice of font in IY, offset from font_data
    ld bc, font_data
    ; offset is a * 6, split out for performance
    rla
    add bc, a   ; bc += (a * 2)
    rla
    add bc, a   ; bc += (a * 4)
    ld iy, bc

    ; Optimisation: Go slow if we cross page boundaries; reg E holds in-page X.
    ; X values that mean we will cross layer 2 page boundary in the next 3px are:
    ; 3E - 00 11111 0
    ; 3F - 00 11111 1
    ; 7E - 01 11111 0
    ; 7F - 01 11111 1
    ; BE - 10 11111 0
    ; BF - 10 11111 1
    ; FE - 11 11111 0
    ; FF - 11 11111 1

    ; Check bits 1, 2, 3, 4, and 5 which they have in common
    ; (~E & 00111110) != 0 -> can use fast char
    ld a, e
    cpl
    and $3e
    jp nz, printLoopFast

    call layer2CharSlow
    jp printLoopNext

.printLoopFast:
    call layer2CharFast

.printLoopNext:
    add de, 4

    ; reset Y
    ld a, l
    sub 5
    ld l, a

    exx
    inc hl ; next char in HL'
    jp printLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _readColourFromIndex
_readColourFromIndex:
    pop hl ; address
    pop bc ; index
    ex (sp), hl ; colour address, put address back

    ld a, c
    nextreg 64, a ; REG_PALETTE_INDEX

    ld bc, $243B
    ld a, 65 ; REG_PALETTE_VALUE_8
    out (c), a
    inc b
    in a, (c)
    ld (hl), a

    inc hl

    dec b
    ld a, 68 ; REG_PALETTE_VALUE_16
    out (c), a
    inc b
    in a, (c)
    ld (hl), a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setHudBackground
_setHudBackground:
    nextreg $43, $11  ; // select palette 0001 0001 and enable ulanext flag

    nextreg 64, 249 ; REG_PALETTE_INDEX <- HUD_BLACK

    ld a, l
    nextreg 68, a ; REG_PALETTE_VALUE_16

    ld a, h
    and 1
    nextreg 68, a ; REG_PALETTE_VALUE_16

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _writeColourToIndex
_writeColourToIndex:
    pop hl ; address
    pop bc ; index
    ex (sp), hl ; colour address, address back on stack

    ld a, c
    nextreg 64, a ; REG_PALETTE_INDEX
    ld a, (hl)
    nextreg 68, a ; REG_PALETTE_VALUE_16
    inc hl
    ld a, (hl)
    nextreg 68, a ; REG_PALETTE_VALUE_16

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setFallbackColour
_setFallbackColour:
    ld a, l
    nextreg $4a, a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _zeroPalette
_zeroPalette:
    call _selectPalette ; index is in L, passed through to this
    
    xor a
    ld b, $FF
.zeroPaletteLoop:
    nextreg 68, a ; REG_PALETTE_VALUE_16
    nextreg 68, a ; REG_PALETTE_VALUE_16
    djnz zeroPaletteLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _selectPalette
_selectPalette:
    ld a, l         ; 0000 xxxx - pallete index
    add a           ; 000x xxx0
    add a           ; 00xx xx00
    add a           ; 0xxx x000
    sli a           ; xxxx 0001 - 1 for enabling ulanext
    nextreg $43, a  ; // select palette using A
    nextreg 64, 0   ; REG_PALETTE_INDEX set to start palette index
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _hideSprite
_hideSprite:
    ld a, l ; sprite index
    nextreg $34, a
    nextreg $38, 0 ; invisible
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _scrollTilemap
_scrollTilemap:
    pop hl ; address
    pop de ; y
    ex (sp), hl ; x

    ld a, h
    nextreg 47, a
    ld a, l
    nextreg 48, a
    ld a, e
    nextreg 49, a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _scrollLayer2
_scrollLayer2:
    pop hl ; address
    pop de ; y
    ex (sp), hl ; x

    ld a, h
    nextreg $71, a
    ld a, l
    nextreg $16, a
    ld a, e
    nextreg $17, a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2StashPalette
_layer2StashPalette:
    ; buffer at HL, 512 bytes
    xor a
    ld bc, $253B
.layer2StashPaletteLoop:
    nextreg 64, a
    ex af, af'
    
    dec b
    ld a, $41
    out (c), a
    inc b
    in e, (c) ; colour main byte

    dec b
    ld a, 68
    out (c), a
    inc b
    in d, (c) ; colour last byte

    ld (hl), de
    inc hl
    inc hl

    ex af, af'
    inc a
    jp nz, layer2StashPaletteLoop
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _updateSprite
_updateSprite:
    ld a, (hl) ; index byte
    nextreg $34, a

    ld iy, hl
    exx
    ld bc, (iy+1) ; targetX
    ld hl, (iy+3) ; y
    ld de, (iy+5) ; z
    
    or a ; clear C
    sbc hl, de  ; targetY (y - z)

    jp nc, updateSpriteScaleNegativeDone
    ld hl, 0
.updateSpriteScaleNegativeDone:

    ld a, (iy+7)  ; scale up
    or a
    jp z, updateSpriteScaleDone
    add bc, -8
    add hl, -8
    ld a, $a
.updateSpriteScaleDone:
    nextreg $39, a

    ld a, c
    nextreg $35, a  ; x low

    ld a, l
    nextreg $36, a  ; y low, y high is always 0

    ld a, (iy+8) ; mirrored?
    or a
    jp z, updateSpriteMirrorDone
    ld a, 8
.updateSpriteMirrorDone:
    or b    ; x high
    nextreg $37, a

    ld a, (iy+9) ; pattern byte
    or $c0  ; // 1'0'PPPPPP ; sprite visible, using pattern
    nextreg $38, a

    exx
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _printSideways
_printSideways:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2PlotSliceSidewaysInk+1), a

    pop HL          ; y
    pop DE          ; x

    exx
    pop hl          ; address of first char in HL'
    push iy         ; put return back on stack

.printSidewaysLoop:
    ld a, (hl) ; read from HL'
    exx
    sub 32 ; index = ascii - 32
    ret c ; exit if char is below 32

    ; put first slice of font in IY, offset from font_data
    ld bc, font_data
    ; offset is a * 6, split out for performance
    rla
    add bc, a   ; bc += (a * 2)
    rla
    add bc, a   ; bc += (a * 4)
    ld iy, bc

    call layer2CharSideways

    add de, -5

    ld a, l
    sub 4 ; move Y up
    ld l, a

    exx
    inc hl ; next char in HL'
    jp printSidewaysLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ulaAttributeChar:
    ; l           ; y
    ; de          ; x + ula attributes
    ; bc          ; address of first slice

    ex de, hl       ; offset = H(row width, 32) * L(y)
    mul d, e
    ex de, hl
    add hl, de      ; HL(attribute address) = offset + x

    ld de, bc

    xor a
    call ulaAttributeCharPlotSlice
    call ulaAttributeCharPlotSlice
    call ulaAttributeCharPlotSlice
    call ulaAttributeCharPlotSlice
    ; fallthrough to ulaAttributeCharPlotSlice

.ulaAttributeCharPlotSlice:
    add hl, 29 ; (32-3)
    ld c, (de)
    inc a
    ld b, 3         ; loops in b
.ulaAttributeCharPlotSliceLoop:
    rl c
    jp nc, ulaAttributeCharPlotSliceSkip
    ld (hl), a
.ulaAttributeCharPlotSliceSkip:
    inc hl
    djnz ulaAttributeCharPlotSliceLoop
    inc de
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
