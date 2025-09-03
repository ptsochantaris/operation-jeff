SECTION code_compiler

PUBLIC _selectLayer2Page
_selectLayer2Page:
    ld      a, 100
    cp      l
    ret     z
    ld      a, l
    ld      (_selectLayer2Page+1), a
    or      $10
    push    bc
    ld      bc, $123b
    out     (bc), a
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
    BSRL DE, B      ; x >> 6 to get L2 page
    ld l, e         ; function expects this at L
    call _selectLayer2Page

layer2Set:
    ld hl, 0         ; in-page x (h) + y (l)
    ld (hl), 0       ; set (hl) to colour value
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2Char
_layer2Char:
    pop iy          ; return address

    pop HL          ; bgColor
    ld a, l
    ld (layer2PlotSliceBg+1), a

    pop HL          ; textColour
    ld a, l
    ld (layer2PlotSliceFg+1), a

    pop HL          ; y
    pop DE          ; x
    add de, 2

    pop bc          ; address of first slice
    push iy         ; put return back on stack

    ld iy, bc

    ld c, (iy)
    call layer2PlotSlice
    inc hl
    add de, 3

    ld c, (iy+1)
    call layer2PlotSlice
    inc hl
    add de, 3

    ld c, (iy+2)
    call layer2PlotSlice
    inc hl
    add de, 3

    ld c, (iy+3)
    call layer2PlotSlice
    inc hl
    add de, 3

    ld c, (iy+4)
    call layer2PlotSlice
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2CharNoBackground
_layer2CharNoBackground:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+4), a

    pop HL          ; y
    pop DE          ; x
    add de, 2

    pop bc          ; address of first slice
    push iy         ; put return back on stack

    ld iy, bc

    ld c, (iy)
    call layer2PlotSliceNoBackground
    inc hl
    add de, 3

    ld c, (iy+1)
    call layer2PlotSliceNoBackground
    inc hl
    add de, 3

    ld c, (iy+2)
    call layer2PlotSliceNoBackground
    inc hl
    add de, 3

    ld c, (iy+3)
    call layer2PlotSliceNoBackground
    inc hl
    add de, 3

    ld c, (iy+4)
    call layer2PlotSliceNoBackground
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    RET
