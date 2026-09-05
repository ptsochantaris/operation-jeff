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

; Both line primitives are degenerate rectangles, so they reshape their arguments
; and drop into the fill core rather than carrying plotting loops of their own.
; That trades ~380 T of extra setup for an inner loop of 11 T/px instead of 54
; (horizontal) or 27 (vertical), so it pays from about 10 px across or 31 px
; down. Every real caller mixes a long side with a short one and comes out ahead:
; the HUD gauge boxes are ~37% faster and layer2circleFill ~8%, and the pair
; costs 35 bytes where the two hand-rolled loops cost 57.
;
; NOTE the asymmetry in the existing contract, which is preserved here:
; layer2HorizonalLine's width is an INCLUSIVE extent (x .. x+width, i.e. width+1
; pixels - that is what makes layer2box's corners meet the vertical edges it
; draws at x+width), while layer2VerticalLine's bottomY is EXCLUSIVE
; (topY .. bottomY-1).

PUBLIC _layer2VerticalLine
_layer2VerticalLine:
    pop iy          ; return address
    pop bc          ; colour in C
    pop hl          ; bottom y in L
    pop de          ; top y in E
    ld a, l
    sub e           ; height = bottom - top (the bottom row is exclusive)
    ld b, a
    ld a, c         ; colour
    ld c, e         ; start y = top
    pop hl          ; x
    push iy         ; put return back on stack
    ld de, 1        ; one column wide
    jp layer2fillInternal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _layer2HorizonalLine
_layer2HorizonalLine:
    pop iy          ; return address
    pop hl          ; colour
    ld a, l
    pop de          ; width
    inc de          ; inclusive extent -> pixel count
    pop hl          ; y
    ld c, l
    pop hl          ; x
    push iy         ; put return back on stack
    ld b, 1         ; one row tall
    jp layer2fillInternal

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

; The rows are unrolled, which drops the per-row counter and the iy walk. The
; slice sits in A and is shifted with add a,a (4t, against 8t for sll b), and
; the colour sits in E so the store is ld (hl),e (7t, against 10t for ld (hl),n)
; - so DE is pushed and popped around the whole thing to free E up.

; Plots the top three bits of the slice in A across one row: HL is the
; destination, E the colour, and H walks right as each bit is consumed.
MACRO PLOTSLICE
    add a, a
    jr nc, $+3
    ld (hl), e
    inc h
    add a, a
    jr nc, $+3
    ld (hl), e
    inc h
    add a, a
    jr nc, $+3
    ld (hl), e
ENDM

layer2CharFast:
    ; HL y
    ; DE x
    ; IY            ; address of first slice

    push de         ; x has to survive, e becomes the colour
    call selectPageForXInDeAndSetupH
    ld c, h         ; stash x
layer2PlotSliceFastInk:
    ld e, 0         ; placeholder for colour value

    ld a, (iy)
    PLOTSLICE
    ld h, c         ; restore x
    inc l           ; y++

    ld a, (iy+1)
    PLOTSLICE
    ld h, c
    inc l

    ld a, (iy+2)
    PLOTSLICE
    ld h, c
    inc l

    ld a, (iy+3)
    PLOTSLICE
    ld h, c
    inc l

    ; the last row does not need x restoring
    ld a, (iy+4)
    PLOTSLICE
    inc l

    pop de          ; restore x
    ret

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
    ; jr, not jp: the set bit skips it (7t) and glyph slices are ~60% set, so
    ; this averages ~9t against jp's flat 10t, and saves a byte
    jr nc, layer2PlotSliceSidewaysNext

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

; Register-level entry point, also used by the two line primitives above.
; in: a = colour, b = height, de = width, c = start y, hl = start x
;     (the return address must already be back on the stack)
layer2fillInternal:
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
    jp fillRunNext      ; jp: 10t, against 12t for an always-taken jr

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

; void layer2circleFill(byte radius, word x, word y, byte colorTop,
;                       byte colorBottom, byte dividerY) __z88dk_callee
;
; Replaces the C version (formerly in screen.c), which cost 318 bytes plus a
; 16-byte always-mapped pointer array, and spent an ix frame and 16-bit
; arithmetic on values that are all bytes.
;
; Rows that share a half-width AND a colour are emitted as ONE rectangle rather
; than one hline each, so a radius-7 disc issues 9-10 fills where the C issued
; 15 hlines. dividerY is a single threshold on a monotonically increasing Y, so
; the colour changes at most once and a width run splits at most once.
;
; Row i (0..2r) uses circleWidths[min(i, 2r-i)] clamped to index r-1. That clamp
; is what makes the middle row come out at `radius`, which is exactly the extra
; middle-row call the C version made after its loop.
;
; Every per-row value lives in an instruction operand rather than a variable:
; the setup patches them once and the loop reads them as immediates, which turns
; each `ld a,(nn)` into `ld a,n` (13T -> 7T, and one byte shorter). That is worth
; ~70T a row and removes the whole 16-byte state block. The run state (length,
; half-width, colour, start y) is patched per run and read back out of the
; operands by cfFlush.
;
; Measured against the C version: 18992 -> 13762 T (-27.5%) for the radius-7
; disc. NOT re-entrant - it patches itself and stashes the return address in an
; operand - which is fine, it is only ever called from the HUD, never an ISR.

GLOBAL circleWidthOffsets, circleWidths      ; the width tables, in bank 28

PUBLIC _layer2circleFill
_layer2circleFill:
    ; __z88dk_callee, NOT __smallc - the 8 arg bytes are packed:
    ; radius, x lo, x hi, y lo, y hi, colorTop, colorBottom, dividerY
    pop hl
    ld (cfRetVal+1), hl

    pop hl              ; L = radius, H = x lo
    ld c, l             ; C = radius, kept across the remaining pops
    ld e, h             ; E = x lo

    pop hl              ; L = x hi, H = y lo
    ld d, l             ; DE = x
    ld a, h
    ld (cfYVal+1), a    ; y - a byte here, the disc sits near the top of screen

    pop hl              ; L = y hi, H = colorTop
    ld a, h
    ld (cfTopVal+1), a

    pop hl              ; L = colorBottom, H = dividerY
    ld a, l
    ld (cfBotVal+1), a
    ld a, h
    ld (cfDivVal+1), a

    ld a, c
    ex de, hl           ; HL = x
    add hl, a
    ld (cfMidVal+1), hl ; mid = x + radius

    add a, a
    ld (cfRowsA+1), a   ; 2 * radius, read at two sites in the loop
    ld (cfRowsB+1), a

    ld a, c
    dec a
    ld (cfClampCp+1), a ; widest row's index, also read at two sites
    ld (cfClampLd+1), a
    ld hl, circleWidthOffsets
    add hl, a
    ld a, (hl)
    ld hl, circleWidths
    add hl, a
    ld (cfWptrVal+1), hl ; this radius' row of the triangular table

    xor a
    ld (cfRunLenVal+1), a   ; no run open yet - MUST be reset, the operand still
                            ; holds the previous call's run length
    ld b, a                 ; B = row index

.cfRowLoop:
.cfRowsA:
    ld a, 0             ; SMC: 2 * radius
    sub b               ; rows - i
    cp b
    jr c, cfHaveC       ; keep the smaller of i and rows-i
    ld a, b
.cfHaveC:
.cfClampCp:
    cp 0                ; SMC: radius - 1
    jr c, cfNoClamp
.cfClampLd:
    ld a, 0             ; SMC: radius - 1
.cfNoClamp:
.cfWptrVal:
    ld hl, 0            ; SMC: this radius' width row
    add hl, a
    ld c, (hl)          ; C = half-width of this row

.cfYVal:
    ld a, 0             ; SMC: start y
    add a, b
    ld e, a             ; E = Y

.cfDivVal:
    ld a, 0             ; SMC: dividerY
    cp e                ; carry when dividerY < Y
.cfTopVal:
    ld a, 0             ; SMC: colorTop
    jr nc, cfHaveCol
.cfBotVal:
    ld a, 0             ; SMC: colorBottom
.cfHaveCol:
    ld d, a             ; D = colour

.cfRunLenVal:
    ld a, 0             ; SMC: open run length
    or a
    jr z, cfNewRun
.cfRunWVal:
    ld a, 0             ; SMC: open run half-width
    cp c
    jr nz, cfBreakRun
.cfRunColVal:
    ld a, 0             ; SMC: open run colour
    cp d
    jr nz, cfBreakRun
    ld hl, cfRunLenVal+1
    inc (hl)            ; this row joins the open run
    jr cfNextRow

.cfBreakRun:
    push bc
    push de
    call cfFlush
    pop de
    pop bc
.cfNewRun:
    ld a, c
    ld (cfRunWVal+1), a
    ld a, d
    ld (cfRunColVal+1), a
    ld a, e
    ld (cfRunYVal+1), a
    ld a, 1
    ld (cfRunLenVal+1), a

.cfNextRow:
.cfRowsB:
    ld a, 0             ; SMC: 2 * radius
    cp b
    jr z, cfDone
    inc b
    jp cfRowLoop        ; jp: out of jr range from the top of the loop

.cfDone:
    call cfFlush
.cfRetVal:
    ld hl, 0            ; SMC: return address
    jp (hl)

; emit the open run as one rectangle: x = mid - w, width = 2w + 1
.cfFlush:
    ld a, (cfRunLenVal+1)
    or a
    ret z

    ld a, (cfRunWVal+1)
    ld c, a
    ld b, 0
.cfMidVal:
    ld hl, 0            ; SMC: mid
    or a
    sbc hl, bc          ; HL = start x

    ld a, c
    add a, a
    inc a
    ld e, a
    ld d, 0             ; DE = pixel count

    ld a, (cfRunLenVal+1)
    ld b, a             ; B = height
.cfRunYVal:
    ld c, 0             ; SMC: run start y
    ld a, (cfRunColVal+1)   ; A = colour
    jp layer2fillInternal   ; rets for us

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
