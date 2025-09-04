SECTION code_compiler

PUBLIC _selectLayer2Page
_selectLayer2Page:
    ld e, l
selectLayer2PageInternal:
    ld a, 100                       ; placeholder
    cp e
    ret z
    ld a, e
    ld (selectLayer2PageInternal+1), a
    or $10                          ; add other L2 flag
    push bc
    ld bc, $123b
    out (bc), a
    pop bc
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2Plot
_layer2Plot:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+4), a

    pop HL          ; y
    pop DE          ; x
    push bc         ; put return back on stack

layer2SlicePlot:
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; l already has y
    ld (layer2Set+1), hl

    ; destination page
    ld b, 6
    BSRL DE, B      ; x >> 6 to get L2 page in E
    call selectLayer2PageInternal

layer2Set:
    ld hl, 0         ; in-page x (h) + y (l)
    ld (hl), 0       ; set (hl) to colour value
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2Char
_layer2Char:
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

    pop iy          ; address of first slice
    push bc         ; put return back on stack

    ld c, (iy)
    call layer2PlotSlice
    ld c, (iy+1)
    call layer2PlotSlice
    ld c, (iy+2)
    call layer2PlotSlice
    ld c, (iy+3)
    call layer2PlotSlice
    ld c, (iy+4)    ; fallthrough to layer2PlotSlice

layer2PlotSlice:
    ld b, 3         ; loops in b
layer2PlotSliceLoop:
    bit 5, c        
    jr z, layer2PlotSliceBg
layer2PlotSliceFg:
    ld a, 0
    jr layer2PlotSliceGo
layer2PlotSliceBg:
    ld a, 0
layer2PlotSliceGo:
    ld (layer2Set+4), a
    push de
    push bc
    push hl
    call layer2SlicePlot
    pop hl
    pop bc
    pop de

    dec de
    srl c
    djnz layer2PlotSliceLoop
    inc hl ; next y
    add de, 3 ; reset DE
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2CharNoBackground
_layer2CharNoBackground:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+4), a

    pop HL          ; y
    pop DE          ; x
    add de, 2

    pop iy          ; address of first slice
    push bc         ; put return back on stack

    ld c, (iy)
    call layer2PlotSliceNoBackground
    ld c, (iy+1)
    call layer2PlotSliceNoBackground
    ld c, (iy+2)
    call layer2PlotSliceNoBackground
    ld c, (iy+3)
    call layer2PlotSliceNoBackground
    ld c, (iy+4)    ; fallthrough to layer2PlotSliceNoBackground

layer2PlotSliceNoBackground:
    ld b, 3         ; loops in b
layer2PlotSliceNoBackgroundLoop:
    bit 5, c
    jr z, layer2PlotSliceSkip
    push de
    push bc
    push hl
    call layer2SlicePlot
    pop hl
    pop bc
    pop de
layer2PlotSliceSkip:
    dec de
    srl c
    djnz layer2PlotSliceNoBackgroundLoop
    inc hl ; next y
    add de, 3 ; reset de
    RET
