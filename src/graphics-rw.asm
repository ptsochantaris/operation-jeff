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
    ret z    ; done if page in A is same as last time
    ld (selectLayer2PageInternal+1), a ; store page for next time
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

; The rectangle is split into runs of columns that live in the same layer 2 page,
; so the page is selected once per run instead of being recomputed per column.
; Each run then picks the loop direction that puts the *longer* side on the inside
; (wide runs walk columns with inc h, tall runs walk rows with inc l), and the
; inner loop is an unrolled block of 8 stores entered part-way for the remainder.
; Height and start y are SMC placeholders, the colour lives in IYH and the run
; length stays in B, so nothing has to be reloaded from memory per run.

PUBLIC _layer2fill
_layer2fill:
    pop iy          ; return address

    pop hl          ; colour
    ld a, l
    pop hl          ; height
    ld b, l
    pop de          ; width
    pop hl          ; start y
    ld c, l
    pop hl          ; start x
    push iy         ; put return back on stack

    ld iyh, a       ; colour stays in IYH for the whole fill

    ld a, d
    or e
    ret z           ; zero width

    ld a, b
    or a
    ret z           ; zero height
    ld (fillHeightValue+1), a

    ld a, c
    ld (fillAcrossY+1), a
    ld (fillDownY+1), a

    ; layer 2 page and in-page x of the left edge
    ld a, l
    and $3f
    ld c, a         ; c = first column of this run
    ld a, l
    and $c0
    or h
    rlca
    rlca
    call selectLayer2PageInternal

.fillRunLoop:
    ; run = min(columns left in this page, width left)
    ld a, 64
    sub c
    ld b, a
    ld a, d
    or a
    jr nz, fillRunClip
    ld a, e
    cp b
    jr nc, fillRunClip
    ld b, e
.fillRunClip:
    ld a, e         ; width left -= run
    sub b
    ld e, a
    jr nc, fillRunBorrowed
    dec d
.fillRunBorrowed:
    push de         ; stash width left, b now holds the run length

.fillHeightValue:
    ld a, 0                     ; placeholder for height
    cp b
    jr c, fillWideRun

    ; tall run: one pass per column, walking rows
    ld iyl, b                   ; columns to do
    ld hl, fillDown
    call fillSetupUnroll        ; a is still the height
    ld (fillDownJump+1), hl
    ld (fillDownPasses+1), a
.fillDownY:
    ld e, 0                     ; placeholder for start y
    ld h, c                     ; run's first column
    ld a, iyh                   ; colour
.fillDownLoop:
    ld l, e                     ; back to the first row
.fillDownPasses:
    ld b, 0                     ; placeholder for pass count
.fillDownJump:
    jp 0                        ; placeholder for entry point
.fillDown:
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    ld (hl), a
    inc l
    djnz fillDown
    inc h                       ; next column
    dec iyl
    jr nz, fillDownLoop
    jr fillRunNext

    ; wide run: one pass per row, walking columns
.fillWideRun:
    ld iyl, a                   ; rows to do
    ld a, b                     ; run length
    ld hl, fillAcross
    call fillSetupUnroll
    ld (fillAcrossJump+1), hl
    ld (fillAcrossPasses+1), a
.fillAcrossY:
    ld l, 0                     ; placeholder for start y
    ld a, iyh                   ; colour
.fillAcrossLoop:
    ld h, c                     ; back to the run's first column
.fillAcrossPasses:
    ld b, 0                     ; placeholder for pass count
.fillAcrossJump:
    jp 0                        ; placeholder for entry point
.fillAcross:
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    ld (hl), a
    inc h
    djnz fillAcross
    inc l                       ; next row
    dec iyl
    jr nz, fillAcrossLoop

.fillRunNext:
    pop de                      ; width left
    ld a, d
    or e
    ret z

    ld a, (selectLayer2PageInternal+1)
    inc a
    call selectLayer2PageInternal
    ld c, 0                     ; later runs start at the page's first column
    jp fillRunLoop

; in:  a = pixels in one pass group (1..255), hl = start of the unrolled block
; out: hl = entry point for the first pass, a = number of passes
.fillSetupUnroll:
    ld b, a
    dec b
    ld a, b
    and 7
    neg
    add a, 7                    ; stores to skip on the first pass
    add a, a                    ; two bytes per store/step pair
    add hl, a
    ld a, b
    rrca
    rrca
    rrca
    and $1f
    inc a                       ; passes = ((count - 1) >> 3) + 1
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
