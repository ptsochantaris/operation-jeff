SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _selectLayer2Page
_selectLayer2Page:
    ld a, l
    jp selectLayer2PageInternal

.selectLayer2PageInternalE:
    ld a, e

.selectLayer2PageInternal:
    cp 100       ; placeholder
    ret z
    ld (selectLayer2PageInternal+1), a
    or $10          ; add other L2 flag
    push bc
    ld bc, $123b
    out (c), a
    pop bc
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2Plot, layer2SlicePlot, layer2Set
_layer2Plot:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+1), a

    pop HL          ; y
    pop DE          ; x
    push bc         ; put return back on stack

.layer2SlicePlot:
    push hl

    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; in-page x (h) + y (l)

    ; destination page
    ld a, b
    ld b, 6
    push de
    BSRL DE, B      ; x >> 6 to get L2 page in E
    ld b, a
    call selectLayer2PageInternalE
    pop de

.layer2Set:
    ld (hl), 0       ; set (hl) to colour value
    pop hl
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

    ; destination page
    ld b, 6
    BSRL DE, B      ; x >> 6 to get L2 page in E
    call selectLayer2PageInternalE

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

    ; destination page, initial
    push de
    ld a, b
    ld b, 6
    BSRL DE, B      ; x >> 6 to get L2 page in E
    ld b, a
    call selectLayer2PageInternalE
    pop de

.layer2HorizontalLineLoop:
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x, set Z flag for below
    ld h, a         ; l already has y

    ; destination page needs update if in-page x is zero
    jp nz, layer2HorizontalLineLoopSet ; or skip
    push de
    ld a, b
    ld b, 6
    BSRL DE, B      ; x >> 6 to get L2 page in E
    ld b, a
    call selectLayer2PageInternalE
    pop de

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
    ;pop HL          ; y
    ;pop DE          ; x
    ;pop iy          ; address of first slice

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
    bit 5, c        
    jp z, layer2PlotSliceBg
.layer2PlotSliceFg:
    ld a, 0
    jp layer2PlotSliceGo
.layer2PlotSliceBg:
    ld a, 0
.layer2PlotSliceGo:
    ld (layer2Set+1), a
    call layer2SlicePlot

    dec de
    srl c
    djnz layer2PlotSliceLoop
    inc l ; next y
    add de, 3 ; reset DE
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC setPaletteCommitGreen, setPaletteCommitRed, setPaletteCommit

setPaletteCommit:
    ld h, a ; 00000BBB - blue expected in A

    and 1
    ld d, a ; 0000000B

    ld a, h ; 00000BBB
    rrca    ; B00000BB
    and 3   ; 000000BB
    ld h, a

    ; d = 0000000B, h = 000000BB
    ; stack: [green][red][address]

.setPaletteCommitGreen:
    ld a, 0
    rlca
    rlca ; 000GGG00
    or h ; 000GGGBB
    ld h, a

.setPaletteCommitRed:
    ld a, 0
    rrca
    rrca
    rrca ; RRR00000
    or h ; RRRGGGBB

    nextreg 68, a ; REG_PALETTE_VALUE_16 ; RRRGGGBB
    ld a, d
    nextreg 68, a ; REG_PALETTE_VALUE_16 ; 0000000B
    ret
