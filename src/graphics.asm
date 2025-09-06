SECTION code_compiler

PUBLIC _mouseHwX
_mouseHwX:
    DW 0
PUBLIC _mouseHwY
_mouseHwY:
    DW 0
PUBLIC _mouseHwB
_mouseHwB:
    DW 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; from the brilliant guide here: http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html

PUBLIC _random16
_random16:
    ld hl,1       ; seed must not be 0
    ld a,h
    rra
    ld a,l
    rra
    xor h
    ld h,a
    ld a,l
    rra
    ld a,h
    rra
    xor l
    ld l,a
    xor h
    ld h,a
    ld (_random16+1),hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _writeNextReg
_writeNextReg:
    pop hl ; return address
    
    pop bc ; len in c
    ld b, c ; will use b to loop for length
    
    pop de ; pointer

    ex (sp), hl ; register in l, return address back on stack
    ld a, l
    ld (writeNextRegSet+2), a ; store the register we'll be writing to

writeNextRegLoop:
    ld a, (de)
    inc de
writeNextRegSet:
    NEXTREG 0, a
    djnz writeNextRegLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _selectLayer2Page
_selectLayer2Page:
    ld e, l
selectLayer2PageInternal:
    ld a, 100       ; placeholder
    cp e
    ret z
selectLayer2PageInternalNoCheck:
    ld a, e
    ld (selectLayer2PageInternal+1), a
    or $10          ; add other L2 flag
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
    ld (layer2Set+1), a

    pop HL          ; y
    pop DE          ; x
    push bc         ; put return back on stack

layer2SlicePlot:
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
    call selectLayer2PageInternal
    pop de

layer2Set:
    ld (hl), 0       ; set (hl) to colour value
    pop hl
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
    ld (layer2Set+1), a
    call layer2SlicePlot

    dec de
    srl c
    djnz layer2PlotSliceLoop
    inc l ; next y
    add de, 3 ; reset DE
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;void printAttributes(const byte *restrict text, byte x, byte y) __z88dk_callee {
;  byte C = *text;
;  while(C != 0) {
;    const byte *base = bFont + (6 * (C - 32));
;    for(byte v=1; v!=6; ++v, ++base, ++y) {
;      byte slice = *base;
;      for(byte h=5; h != 8; ++h) {
;        if(slice & (1 << h)) {
;            *(byte *)((ulaAttributes + x + 8 - h) + (y * 32)) = v;
;        }
;      }
;    }
;    C = *(++text);
;    x += 4;
;    y -= 5;
;  }
;}

PUBLIC _ulaAttributeChar
_ulaAttributeChar:
    pop bc          ; return address
    pop hl          ; y
    ld h, 32
    pop de          ; x
    pop iy          ; address of first slice
    push bc         ; put return back on stack

    add de, $7804   ; ula attributes: 0x6000 + 0x1800 (see tilemap.h) = 0x7800, with a minor X offset

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

ulaAttributeCharPlotSlice:
    ld b, 3         ; loops in b
ulaAttributeCharPlotSliceLoop:
    bit 5, c
    jr z, ulaAttributeCharPlotSliceSkip

    push hl

    add hl, a ; y + current row from A

    ex de, hl
    mul d, e
    ex de, hl

    add hl, de ; y+x
    ld (hl), a

    pop hl

ulaAttributeCharPlotSliceSkip:
    dec de
    srl c
    djnz ulaAttributeCharPlotSliceLoop

    add de, 3 ; reset x
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2CharNoBackground
_layer2CharNoBackground:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+1), a

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
    call layer2SlicePlot
layer2PlotSliceSkip:
    dec de
    srl c
    djnz layer2PlotSliceNoBackgroundLoop
    inc l ; next y
    add de, 3 ; reset de
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2CharSidewaysNoBackground
_layer2CharSidewaysNoBackground:
    pop bc          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2Set+1), a

    pop HL          ; y
    dec l
    dec l
    pop DE          ; x

    pop iy          ; address of first slice
    push bc         ; put return back on stack

    ld c, (iy)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+1)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+2)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+3)
    call layer2PlotSliceSidewaysNoBackground
    ld c, (iy+4)    ; fallthrough to layer2PlotSliceSidewaysNoBackground

layer2PlotSliceSidewaysNoBackground:
    ld b, 3         ; loops in b
layer2PlotSliceSidewaysNoBackgroundLoop:
    bit 5, c
    jr z, layer2PlotSliceSidewaysSkip
    call layer2SlicePlot
layer2PlotSliceSidewaysSkip:
    inc l
    srl c
    djnz layer2PlotSliceSidewaysNoBackgroundLoop
    inc de ; next x
    dec l
    dec l
    dec l
    RET

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
    call selectLayer2PageInternal

    ; number of loops
    ld a, l
    sub c
    ld b, a

layer2VerticalLineLoopSet:
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
    call selectLayer2PageInternal
    pop de

layer2HorizontalLineLoop:
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x
    ld h, a         ; l already has y

    or a            ; destination page needs update if in-page x is zero
    jr nz, layer2HorizontalLineLoopSet ; or skip
    push de
    ld a, b
    ld b, 6
    BSRL DE, B      ; x >> 6 to get L2 page in E
    ld b, a
    call selectLayer2PageInternalNoCheck
    pop de

layer2HorizontalLineLoopSet:
    ld (hl), 0       ; set (hl) to colour value

    inc de
    dec bc
    ld a, b
    or c
    jr nz, layer2HorizontalLineLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2StashPalette
_layer2StashPalette:
    ; buffer at HL, 512 bytes
    xor a
    ld bc, $253B
layer2StashPaletteLoop:
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
    jr nz, layer2StashPaletteLoop
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
    sbc hl, bc  ; targetY (y - z)
    ex de, hl ; put y back into DE
    pop bc

    jr nc, updateSpriteScaleNegativeDone
    ld de, 0
updateSpriteScaleNegativeDone:

    ld a, (hl)  ; scale up
    inc hl
    or a
    jr nz, updateSpriteScale
    xor a   ; clear a
    jr updateSpriteScaleDone
updateSpriteScale:
    add bc, -8
    add de, -8
    ld a, $a
updateSpriteScaleDone:
    nextreg $39, a

    ld a, c
    nextreg $35, a  ; x low

    ld a, e
    nextreg $36, a  ; y low, y high is always 0

    ld a, (hl) ; mirrored?
    inc hl
    or a
    jr nz, updateSpriteMirror
    xor a ; clear
    jr updateSpriteMirrorDone
updateSpriteMirror:
    ld a, 8
updateSpriteMirrorDone:
    or b    ; targetX high
    nextreg $37, a

    ld a, (hl) ; pattern byte
    or $c0  ; // 1'0'PPPPPP ; sprite visible, using pattern
    nextreg $38, a

    RET
