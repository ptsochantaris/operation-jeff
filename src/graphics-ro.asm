SECTION PAGE_28_POSTISR

GLOBAL _mmu3Borrow, _mmu3Return, _bootColour, font_data, setPaletteCommitRed, setPaletteCommitGreen, setPaletteCommit
GLOBAL selectLayer2PageInternal, selectPageForXInDeAndSetupH
GLOBAL _waitFrame

; The palette buffer lives in the banked scratch page - see SCRATCH_PAGE and
; PALETTE_BUFFER_OFFSET in utility.h, which these must match. The fades borrow
; MMU3 for it around each pass, and hand it back before waiting for the frame.
SCRATCH_PAGE   equ 213
PALETTE_BUFFER equ $6000 + $0800

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

    push bc             ; ceiling/floor
    push hl             ; colour count
    ld l, SCRATCH_PAGE
    call _mmu3Borrow    ; uses a and bc; the page it displaced comes back in l
    ld a, l
    pop hl
    pop bc
    push af             ; keep that page, to put back at the end
    ld de, PALETTE_BUFFER

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

    pop af
    ld l, a
    call _mmu3Return    ; MMU3 back as it was, before the wait
    call _waitFrame
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setPaletteFloor
_setPaletteFloor:
    pop hl      ; address
    pop bc      ; floor in C
    ex (sp), hl ; colour count in HL (2 bytes per colour), address back on stack

    push bc             ; ceiling/floor
    push hl             ; colour count
    ld l, SCRATCH_PAGE
    call _mmu3Borrow    ; uses a and bc; the page it displaced comes back in l
    ld a, l
    pop hl
    pop bc
    push af             ; keep that page, to put back at the end
    ld de, PALETTE_BUFFER

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

    pop af
    ld l, a
    call _mmu3Return    ; MMU3 back as it was, before the wait
    call _waitFrame
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

; Flatten a palette to the boot colour. A screen blitted in under this stays
; invisible, which is what the cold boot path wants: the raster arrives while
; the palette still belongs to the loading screen, and holding the orange is
; a lot less jarring than blacking the palette out to hide it.
;
; This replaces _zeroPalette, which lost its last caller when the cold boot
; title load started holding the boot colour instead of blacking out.

PUBLIC _floodPaletteWithBootColour
_floodPaletteWithBootColour:
    call _selectPalette ; mask is in L, passed through to this, and it also resets the palette index to 0

    ld hl, (_bootColour) ; L gets the packed RRRGGGBB byte, H the odd blue bit
    ld b, 0 ; djnz treats 0 as 256, so all 256 palette entries are written
.floodPaletteWithBootColourLoop:
    ld a, l
    nextreg 68, a ; REG_PALETTE_VALUE_16
    ld a, h
    nextreg 68, a ; REG_PALETTE_VALUE_16
    djnz floodPaletteWithBootColourLoop

    RET

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

GLOBAL mouseSprite

PUBLIC _updateMouse
_updateMouse:
    call _waitFrame      ; wait for the ULA frame (CTC-safe), then update sprite
    ld hl, mouseSprite
    ; fallthrough to _updateSprite

PUBLIC _updateSprite
_updateSprite:
    ; All the work happens in the shadow set, so BC/DE/HL survive - the header
    ; declares __preserves_regs(b,c,d,e,h,l) to cash that in at the call sites.
    ; Only A, the flags and IY are clobbered (nothing on the C side uses IY).
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
    ; jr, not jp: glyph slices are ~60% set bits, so the
    ; not-taken path (7t) is the common one and this beats jp's flat 10t
    jr nc, ulaAttributeCharPlotSliceSkip
    ld (hl), a
.ulaAttributeCharPlotSliceSkip:
    inc hl
    djnz ulaAttributeCharPlotSliceLoop
    inc de
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Half-widths of each row of a filled disc, for _layer2circleFill (graphics-rw.asm).
; A triangular table: radius r occupies r bytes starting at circleWidthOffsets[r-1],
; and row i of the disc uses index min(i, 2r-i) clamped to r-1.
;
; These are NOT true circles - a real one would give {4,5,6,6,7,7,7} for r=7, but the
; top row is deliberately narrowed to 2 so a 15-pixel disc reads as round rather than
; blocky. So they cannot be computed (from the plasma sine table or otherwise) without
; changing the artwork.
;
; Only r=7 (the kill counter) and r=8 (initHud) are actually called today; the other
; six rows cost 21 bytes and are kept so the routine stays general.

PUBLIC circleWidthOffsets, circleWidths

circleWidthOffsets: DB 0, 1, 3, 6, 10, 15, 21, 28
circleWidths:
    DB 1
    DB 1,2
    DB 2,2,3
    DB 2,3,3,4
    DB 2,4,4,5,5
    DB 2,4,5,5,6,6
    DB 2,4,5,6,6,7,7
    DB 2,4,5,6,7,7,8,8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
