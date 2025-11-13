SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC selectPageForXInDeAndSetupH, selectPageForXInDE
selectPageForXInDeAndSetupH:
    ld a, e         ; e has X
    and $3F         ; keep in-page x distance
    ld h, a         ; l already has y, h is now in-page x
    ; fallthrough to selectPageForXInDE

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
    or $10  ; bit 4 = on, signifies that this is a bank offset command
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

    call selectPageForXInDeAndSetupH

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

    pop hl          ; colour
    ld a, l
    ld (layer2HorizontalLineLoopSet+1), a

    pop de          ; width
    inc de          ; make inclusive
    ld b, e         ; 16bit loop init
    dec de
    inc d
    ld c, d         ; BC set for 16bit loop

    pop hl          ; y
    pop de          ; start x
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

    ; 16-bit loop using BC
    djnz layer2HorizontalLineLoop
    dec c
    jp nz, layer2HorizontalLineLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC setPaletteCommitGreen, setPaletteCommitRed, setPaletteCommit

setPaletteCommit:
    exx
    ld h, a ; xxxxxBBB - blue expected in A

    and 1
    ld l, a ; 0000000B

    ld a, h ; xxxxxBBB
    rrca    ; BxxxxxBB
    and 3   ; 000000BB
    ld h, a

    ; l = 0000000B, h = 000000BB

.setPaletteCommitGreen:
    ld a, 0 ; placeholder  00000GGG
    rlca
    rlca ; 000GGG00
    or h ; 000GGGBB
    ld h, a

    ; l = 0000000B, h = 000GGGBB

.setPaletteCommitRed:
    ld a, 0 ; placeholder 00000RRR
    rrca
    rrca
    rrca ; RRR00000
    or h ; RRRGGGBB
    nextreg 68, a ; REG_PALETTE_VALUE_16 ; RRRGGGBB

    ld a, l
    nextreg 68, a ; REG_PALETTE_VALUE_16 ; 0000000B
    exx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2CharSlow, layer2CharFast, layer2PlotSliceFastInk, layer2PlotSliceSlowInk

layer2CharSlow:
    ; HL y
    ; DE x
    ; IY            ; address of first slice

    ld (layer2PlotSliceSlowSet+1), de   ; stash x
    ld c, 5         ; 5 slices

.layer2PlotSliceSlowOuterLoop:
    ld b, (iy)
.layer2PlotSliceSlowLoop:
    sll b           ; shift left, add 1 for looping
    jr nc, layer2PlotSliceSlowNext

    call selectPageForXInDeAndSetupH
layer2PlotSliceSlowInk:
    ld (hl), 0      ; set (hl) to colour value

.layer2PlotSliceSlowNext:
    inc de
    ; remove 1, loop if there are still 1s in the slice
    djnz layer2PlotSliceSlowLoop
.layer2PlotSliceSlowSet:
    ld de, 0        ; restore x
    inc l           ; next y
    dec c           ; next loop
    ret z           ; or done

    inc iy          ; next slice
    jp layer2PlotSliceSlowOuterLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

layer2CharFast:
    ; HL y
    ; DE x
    ; IY            ; address of first slice

    call selectPageForXInDeAndSetupH
    ld c, h         ; stash x

    ld a, 5         ; 5 slices
.layer2PlotSliceFastOuterLoop:
    ld b, (iy)      ; current slice
.layer2PlotSliceFastLoop:
    sll b
    jr nc, layer2PlotSliceFastNext
layer2PlotSliceFastInk:
    ld (hl), 0      ; set (hl) to colour value
.layer2PlotSliceFastNext:
    inc h           ; x++

    ; remove 1, loop if there are still 1s in the slice
    djnz layer2PlotSliceFastLoop

    ld h, c         ; restore x
    inc l           ; y++
    dec a           ; next loop
    ret z           ; or done

    inc iy          ; next slice
    jp layer2PlotSliceFastOuterLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC layer2CharSideways, layer2PlotSliceSidewaysInk
layer2CharSideways:
    ; HL          ; y
    ; DE          ; x
    ; IY          ; address of first slice

    ld h, l
    ld c, (iy)
    call layer2PlotSliceSideways
    ld c, (iy+1)
    call layer2PlotSliceSideways
    ld c, (iy+2)
    call layer2PlotSliceSideways
    ld c, (iy+3)
    call layer2PlotSliceSideways
    ld c, (iy+4)    ; fallthrough to layer2PlotSliceSideways

.layer2PlotSliceSideways:
    ld b, 3         ; loops in b
.layer2PlotSliceSidewaysLoop:
    rl c
    jp nc, layer2PlotSliceSidewaysNext

    ld a, h         ; save H
    ex af, af'
    call selectPageForXInDeAndSetupH
.layer2PlotSliceSidewaysInk:
    ld (hl), 0      ; set (hl) to colour value
    ex af, af'
    ld h, a         ; restore H

.layer2PlotSliceSidewaysNext:
    dec l
    djnz layer2PlotSliceSidewaysLoop
    inc de ; next x
    ld l, h
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2fill
_layer2fill:
    pop iy          ; return address

    pop HL          ; colour
    ld a, l
    ld (layer2fillInk+1), a

    pop de          ; height
    ld a, e
    ld (layer2fillVertical+1), a

    pop de          ; width
    ld b, e         ; 16bit loop init
    dec de
    inc d
    ld c, d         ; BC set for 16bit loop

    pop hl          ; start y
    pop de          ; start x
    push iy         ; put return back on stack

    call selectPageForXInDE

.layer2FillLoop:
    ; offset in page
    ld a, e
    and $3F         ; keep in-page bits of x, set Z flag for below
    ld h, a         ; l already has y

    ; destination page needs update if in-page x is zero
    call z, selectPageForXInDE

    push bc
.layer2fillVertical:
    ld b, 0         ; placeholder for height loop
    ld c, l         ; stash L
.layer2fillInk:
    ld (hl), 0      ; set (hl) to colour value
    inc l
    djnz layer2fillInk
    ld l, c         ; restore L
    pop bc
 
    inc de          ; x++

    ; 16-bit loop using BC
    djnz layer2FillLoop
    dec c
    jp nz, layer2FillLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
