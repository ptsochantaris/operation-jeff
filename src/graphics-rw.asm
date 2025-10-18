SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC selectPageForXInDE
selectPageForXInDE:
    ; DE >> 6 to get L2 page in A
    ld a, e ; EExxxxxx
    and $c0 ; EE000000
    or d    ; EEDDDDDD
    rlca    ; EDDDDDDE
    rlca    ; DDDDDDEE
    ; fallthrough to selectLayer2PageInternal

PUBLIC selectLayer2PageInternal
selectLayer2PageInternal:
    cp 99    ; placeholder, intentionally not zero
    ret z
    ld (selectLayer2PageInternal+1), a
    or $10  ; add other L2 flag
    exx
    ld bc, $123b
    out (c), a
    exx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2VerticalLine
_layer2VerticalLine:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2VerticalLineLoopSet+2), a

    pop HL          ; bottom y in L (high number)
    pop BC          ; top y in C (low number)
    pop DE          ; x
    push iy         ; put return back on stack

    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; l already has y, h is now in-page x

    call selectPageForXInDE

    ; number of loops
    ld a, l
    sub c
    ld b, a

.layer2VerticalLineLoopSet:
    dec l
    ld (hl), 0       ; set (hl) to colour value
    djnz layer2VerticalLineLoopSet
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2HorizonalLine
_layer2HorizonalLine:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2HorizontalLineLoopSet+1), a

    pop BC          ; width
    inc bc          ; make inclusive
    pop HL          ; y
    pop DE          ; start x
    push iy         ; put return back on stack

    call selectPageForXInDE

.layer2HorizontalLineLoop:
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x, set Z flag for below
    ld h, a         ; l already has y

    ; destination page needs update if in-page x is zero
    call z, selectPageForXInDE

.layer2HorizontalLineLoopSet:
    ld (hl), 0       ; set (hl) to colour value

    inc de
    dec bc
    ld a, b
    or c
    jp nz, layer2HorizontalLineLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2Char, layer2PlotSliceBg, layer2PlotSliceFg
layer2Char:
    ; HL - y
    ; DE - x
    ; iy - address of first slice

    ld (layer2PlotSliceSet+1), de ; baseline X

    ld c, (iy)
    call layer2PlotSlice
    ld c, (iy+1)
    call layer2PlotSlice
    ld c, (iy+2)
    call layer2PlotSlice
    ld c, (iy+3)
    call layer2PlotSlice
    ld c, (iy+4)    ; fallthrough to layer2PlotSlice

.layer2PlotSlice:
    ld b, 3         ; loops in b
.layer2PlotSliceLoop:
    call selectPageForXInDE
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; in-page x (h) + y (l)

    bit 5, c        
    jp z, layer2PlotSliceBg
.layer2PlotSliceFg:
    ld (hl), 0      ; set (hl) to colour value
    jp layer2PlotSliceNext
.layer2PlotSliceBg:
    ld (hl), 0      ; set (hl) to colour value
.layer2PlotSliceNext:

    dec de
    srl c
    djnz layer2PlotSliceLoop
    inc l ; next y
.layer2PlotSliceSet:
    ld de, 0 ; placeholder
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC setPaletteCommitGreen, setPaletteCommitRed, setPaletteCommit

setPaletteCommit:
    ld h, a ; xxxxxBBB - blue expected in A

    and 1
    ld d, a ; 0000000B

    ld a, h ; xxxxxBBB
    rrca    ; BxxxxxBB
    and 3   ; 000000BB
    ld h, a

    ; d = 0000000B, h = 000000BB
    ; stack: [green][red][address]

.setPaletteCommitGreen:
    ld a, 0 ; placeholder  00000GGG
    rlca
    rlca ; 000GGG00
    or h ; 000GGGBB
    ld h, a

.setPaletteCommitRed:
    ld a, 0 ; placeholder 00000RRR
    rrca
    rrca
    rrca ; RRR00000
    or h ; RRRGGGBB

    nextreg 68, a ; REG_PALETTE_VALUE_16 ; RRRGGGBB
    ld a, d
    nextreg 68, a ; REG_PALETTE_VALUE_16 ; 0000000B
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC ulaAttributeChar
ulaAttributeChar:
    ; l           ; y
    ; de          ; x + ula attributes
    ; iy          ; address of first slice

    ld (ulaAttributeCharPlotSliceLoopReset+1), hl

    xor a
    ld c, (iy)
    call ulaAttributeCharPlotSlice

    ld c, (iy+1)
    call ulaAttributeCharPlotSlice

    ld c, (iy+2)
    call ulaAttributeCharPlotSlice

    ld c, (iy+3)
    call ulaAttributeCharPlotSlice

    ld c, (iy+4)    ; fallthrough to ulaAttributeCharPlotSlice

.ulaAttributeCharPlotSlice:
    inc a
    ld b, 3         ; loops in b

    add hl, a ; y + current row from A
    ex de, hl
    mul d, e
    ex de, hl
    add hl, de ; y+x

.ulaAttributeCharPlotSliceLoop:
    bit 5, c
    jp z, ulaAttributeCharPlotSliceSkip
    ld (hl), a
.ulaAttributeCharPlotSliceSkip:
    dec hl
    srl c
    djnz ulaAttributeCharPlotSliceLoop
.ulaAttributeCharPlotSliceLoopReset:
    ld hl, 0 ; placeholder
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2CharNoBackground, layer2PlotSliceNoBackgroundInk
layer2CharNoBackground:
    ; HL y
    ; DE x

    ld (layer2PlotSliceNoBackgroundSet+1), de

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
    jp z, layer2PlotSliceNoBackgroundNext

    call selectPageForXInDE
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; in-page x (h) + y (l)    
layer2PlotSliceNoBackgroundInk:
    ld (hl), 0      ; set (hl) to colour value

.layer2PlotSliceNoBackgroundNext:
    dec de
    srl c
    djnz layer2PlotSliceNoBackgroundLoop
    inc l ; next y
.layer2PlotSliceNoBackgroundSet:
    ld de, 0 ; placeholder
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2CharSidewaysNoBackground, layer2PlotSliceSidewaysNoBackgroundInk
layer2CharSidewaysNoBackground:
    ; HL          ; y
    ; DE          ; x
    ; iy          ; address of first slice

    ld h, l
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
    jp z, layer2PlotSliceSidewaysNoBackgroundNext

    call selectPageForXInDE

    ld a, h         ; save H
    ex af, af'
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; in-page x (h) + y (l)
.layer2PlotSliceSidewaysNoBackgroundInk:
    ld (hl), 0      ; set (hl) to colour value
    ex af, af'
    ld h, a         ; restore H

.layer2PlotSliceSidewaysNoBackgroundNext:
    inc l
    srl c
    djnz layer2PlotSliceSidewaysNoBackgroundLoop
    inc de ; next x
    ld l, h
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
