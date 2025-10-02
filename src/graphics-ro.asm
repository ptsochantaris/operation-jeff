SECTION PAGE_28_POSTISR

GLOBAL _paletteBuffer, _font_data, setPaletteCommitRed, setPaletteCommitGreen, setPaletteCommit, layer2SlicePlot, layer2Set, layer2Char, layer2PlotSliceBg, layer2PlotSliceFg

PUBLIC _setPaletteCeiling
_setPaletteCeiling:
    pop bc ; address
    pop hl ; ceiling in L
    pop de ; colour count in DE (2 bytes per colour)
    push bc ; return address

    ld iy, _paletteBuffer

    nextreg 64, 0 ; REG_PALETTE_INDEX

    ld b, e ; 8 bit loop, we keep D for later
    
.setPaletteCeilingLoop:
    ld c, (iy)
    inc iy

    ld a, c     ; RRRGGGBB
    rlca
    rlca
    rlca        ; GGGBBRRR
    and 7       ; 00000RRR

    cp l
    jr c, setPaletteCeilingRedBelowCeiling
    ld a, l
.setPaletteCeilingRedBelowCeiling:
    ld (setPaletteCommitRed+1), a

    ld a, c     ; RRRGGGBB
    rrca
    rrca        ; BBRRRGGG
    and 7       ; 00000GGG

    cp l
    jr c, setPaletteCeilingGreenBelowCeiling
    ld a, l
.setPaletteCeilingGreenBelowCeiling:
    ld (setPaletteCommitGreen+1), a

    ld a, c     ; RRRGGGBB
    rlca        ; RRGGGBBR
    and 6       ; 00000BB0
    ld c, a

    ld a, (iy)  ; XXXXXXXB
    inc iy
    and 1       ; 0000000B
    or c        ; 00000BBB

    cp l
    jr c, setPaletteCeilingBlueBelowCeiling
    ld a, l
.setPaletteCeilingBlueBelowCeiling:

    call setPaletteCommit
    djnz setPaletteCeilingLoop

    halt
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setPaletteFloor
_setPaletteFloor:
    pop bc ; address
    pop hl ; ceiling in L
    pop de ; colour count in DE (2 bytes per colour)
    push bc ; return address

    ld iy, _paletteBuffer

    nextreg 64, 0 ; REG_PALETTE_INDEX

    ld b, e ; 8 bit loop, we keep D for later
    
.setPaletteFloorLoop:
    ld c, (iy)
    inc iy

    ld a, c     ; RRRGGGBB
    rlca
    rlca
    rlca        ; GGGBBRRR
    and 7       ; 00000RRR

    cp l
    jr nc, setPaletteFloorRedAboveFloor
    ld a, l
.setPaletteFloorRedAboveFloor:
    ld (setPaletteCommitRed+1), a

    ld a, c     ; RRRGGGBB
    rrca
    rrca        ; BBRRRGGG
    and 7       ; 00000GGG

    cp l
    jr nc, setPaletteFloorGreenAboveFloor
    ld a, l
.setPaletteFloorGreenAboveFloor:
    ld (setPaletteCommitGreen+1), a

    ld a, c     ; RRRGGGBB
    rlca        ; RRGGGBBR
    and 6       ; 00000BB0
    ld c, a

    ld a, (iy)  ; XXXXXXXB
    inc iy
    and 1       ; 0000000B
    or c        ; 00000BBB

    cp l
    jr nc, setPaletteFloorBlueAboveFloor
    ld a, l
.setPaletteFloorBlueAboveFloor:

    call setPaletteCommit
    djnz setPaletteFloorLoop

    halt
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _printAttributes
_printAttributes:
    pop bc          ; return address

    pop HL          ; y
    ld h, 32        ; will be using for multiplication

    pop DE          ; x
    add de, $77E3   ; ula attributes: 0x6000 + 0x1800 (see tilemap.h) = 0x7800, - 32 (one row) + 3 (initial char width)

    pop iy          ; address of first char
    push bc         ; put return back on stack
    ld bc, iy

.printAttributesLoop:
    ld a, (bc)
    or a
    ret z ; exit if char is zero

    ; put first slice of font in IY
    sub 32
    exx
    ld d, a
    ld e, 6
    mul d, e
    add de, _font_data
    ld iy, de
    exx

    push bc
    call ulaAttributeChar
    pop bc

    inc bc ; next char
    add de, 4 ; move X to the right
    jp printAttributesLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ulaAttributeChar:
    ; l           ; y
    ; de          ; x + ula attributes
    ; iy          ; address of first slice

    ld a, 1
    ld c, (iy)
    call ulaAttributeCharPlotSlice

    inc a
    ld c, (iy+1)
    call ulaAttributeCharPlotSlice

    inc a
    ld c, (iy+2)
    call ulaAttributeCharPlotSlice

    inc a
    ld c, (iy+3)
    call ulaAttributeCharPlotSlice

    inc a
    ld c, (iy+4)    ; fallthrough to ulaAttributeCharPlotSlice

.ulaAttributeCharPlotSlice:
    ld b, 3         ; loops in b
.ulaAttributeCharPlotSliceLoop:
    bit 5, c
    jp z, ulaAttributeCharPlotSliceSkip

    push hl

    add hl, a ; y + current row from A

    ex de, hl
    mul d, e
    ex de, hl

    add hl, de ; y+x
    ld (hl), a

    pop hl

.ulaAttributeCharPlotSliceSkip:
    dec de
    srl c
    djnz ulaAttributeCharPlotSliceLoop

    add de, 3 ; reset x
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2CharSidewaysNoBackground
layer2CharSidewaysNoBackground:
    ; HL          ; y
    ; DE          ; x
    ; iy          ; address of first slice

    ld c, (iy)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+1)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+2)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+3)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+4)    ; fallthrough to layer2PlotSliceSidewaysNoBackground

.layer2PlotSliceSidewaysNoBackground:
    ld b, 3         ; loops in b
.layer2PlotSliceSidewaysNoBackgroundLoop:
    bit 5, c
    call nz, layer2SlicePlot
    inc l
    srl c
    djnz layer2PlotSliceSidewaysNoBackgroundLoop
    inc de ; next x
    dec l
    dec l
    dec l
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

layer2CharNoBackground:
    ;pop HL          ; y
    ;pop DE          ; x

    ld c, (iy)
    call layer2PlotSliceNoBackground
    ld c, (iy+1)
    call layer2PlotSliceNoBackground
    ld c, (iy+2)
    call layer2PlotSliceNoBackground
    ld c, (iy+3)
    call layer2PlotSliceNoBackground
    ld c, (iy+4)    ; fallthrough to layer2PlotSliceNoBackground

.layer2PlotSliceNoBackground:
    ld b, 3         ; loops in b
.layer2PlotSliceNoBackgroundLoop:
    bit 5, c
    call nz, layer2SlicePlot
    dec de
    srl c
    djnz layer2PlotSliceNoBackgroundLoop
    inc l ; next y
    add de, 3 ; reset de
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _printNoBackground
_printNoBackground:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+1), a

    pop HL          ; y
    pop DE          ; x
    add de, 2

    pop iy          ; address of first char
    push bc         ; put return back on stack
    ld bc, iy

.printNoBackgroundLoop:
    ld a, (bc)
    or a
    ret z ; exit if char is zero

    ; put first slice of font in IY
    sub 32
    exx
    ld d, a
    ld e, 6
    mul d, e
    add de, _font_data
    ld iy, de
    exx

    push bc
    call layer2CharNoBackground
    pop bc
    ld a, l
    sub 5
    ld l, a

    inc bc ; next char
    add de, 4 ; move X to the right
    jp printNoBackgroundLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    inc hl

    ld bc, (hl) ; targetX
    inc hl
    inc hl

    ld de, (hl) ; y
    inc hl
    inc hl

    push bc
    ld bc, (hl) ; z
    inc hl
    inc hl

    ex de, hl ; swap y into HL to subtract
    or a ; clear C
    sbc hl, bc  ; targetY (y - z)
    ex de, hl ; put y back into DE
    pop bc

    jp nc, updateSpriteScaleNegativeDone
    ld de, 0
.updateSpriteScaleNegativeDone:

    ld a, (hl)  ; scale up
    inc hl
    or a
    jp z, updateSpriteScaleDone
    add bc, -8
    add de, -8
    ld a, $a
.updateSpriteScaleDone:
    nextreg $39, a

    ld a, c
    nextreg $35, a  ; x low

    ld a, e
    nextreg $36, a  ; y low, y high is always 0

    ld a, (hl) ; mirrored?
    inc hl
    or a
    jp z, updateSpriteMirrorDone
    ld a, 8
.updateSpriteMirrorDone:
    or b    ; targetX high
    nextreg $37, a

    ld a, (hl) ; pattern byte
    or $c0  ; // 1'0'PPPPPP ; sprite visible, using pattern
    nextreg $38, a

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _printSidewaysNoBackground
_printSidewaysNoBackground:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+1), a

    pop HL          ; y
    pop DE          ; x

    pop iy          ; address of first char
    push bc         ; put return back on stack
    ld bc, iy

.printSidewaysNoBackgroundLoop:
    ld a, (bc)
    or a
    ret z ; exit if char is zero

    ; put first slice of font in IY
    sub 32
    exx
    ld d, a
    ld e, 6
    mul d, e
    add de, _font_data
    ld iy, de
    exx

    push bc
    call layer2CharSidewaysNoBackground
    pop bc

    add de, -5

    inc bc ; next char
    
    ld a, l
    sub 4 ; move Y up
    ld l, a
    jp printSidewaysNoBackgroundLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print
_print:
    pop bc          ; return address

    pop HL          ; bgColor
    ld a, l
    ld (layer2PlotSliceBg+1), a

    pop HL          ; textColour
    ld a, l
    ld (layer2PlotSliceFg+1), a

    pop HL          ; y
    pop DE          ; x
    add de, 2

    pop iy          ; address of first char
    push bc         ; put return back on stack
    ld bc, iy

.printLoop:
    ld a, (bc)
    or a
    ret z ; exit if char is zero

    ; put first slice of font in IY
    sub 32
    exx
    ld d, a
    ld e, 6
    mul d, e
    add de, _font_data
    ld iy, de
    exx

    push bc
    call layer2Char
    pop bc
    ld a, l
    sub 5
    ld l, a

    inc bc ; next char
    add de, 4 ; move X to the right
    jp printLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
