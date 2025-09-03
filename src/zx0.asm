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

PUBLIC _layer2PlotSlice
_layer2PlotSlice:
        pop bc          ; return address

        pop HL          ; bgColor
        ld a, l
        ld (layer2PlotSliceBg+1), a

        pop HL          ; textColour
        ld a, l
        ld (layer2PlotSliceFg+1), a

        pop HL          ; y
        pop DE          ; x
        add de, 7

        pop iy          ; slice
        push bc         ; put return back on stack

        ld c, iyl       ; pattern in C
        ld b, 3         ; loops
        
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

PUBLIC _layer2PlotSliceNoBackground
_layer2PlotSliceNoBackground:
        pop bc          ; return address

        pop HL          ; colour
        ld a, l
        ld (layer2Set+4), a

        pop HL          ; y
        pop DE          ; x
        add de, 7

        pop iy          ; slice
        push bc         ; put return back on stack

        ld c, iyl       ; pattern in C
        ld b, 3         ; loops

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

; ZX0 decompressor from here: https://github.com/einar-saukas/ZX0/blob/main/z80/dzx0_fast.asm
PUBLIC _decompressZX0
_decompressZX0:
        pop bc          ; return
        pop hl          ; source
        pop de          ; destination
        push bc

        ld      ix, CopyMatch1
        ld      bc, $ffff
        ld      (PrevOffset+1), bc      ; default offset is -1
        inc     bc
        ld      a, $80
        jr      RunOfLiterals           ; BC is assumed to contains 0 most of the time

ShorterOffsets:
        ld      b, $ff                  ; the top byte of the offset is always $FF
        ld      c, (hl)
        inc     hl
        rr      c
        ld      (PrevOffset+1), bc
        jr      nc, LongerMatch

CopyMatch2:                             ; the case of matches with len=2
        ld      bc, 2

        ; the faster match copying code
CopyMatch1:
        push    hl                      ; preserve source

PrevOffset:
        ld      hl, $ffff               ; restore offset (default offset is -1)
        add     hl, de                  ; HL = dest - offset
        ldir
        pop     hl                      ; restore source

        ; after a match you can have either
        ; 0 + <elias length> = run of literals, or
        ; 1 + <elias offset msb> + [7-bits of offset lsb + 1-bit of length] + <elias length> = another match
AfterMatch1:
        add     a, a
        jr      nc, RunOfLiterals

UsualMatch:                             ; this is the case of usual match+offset
        add     a, a
        jr      nc, LongerOffets
        jr      nz, ShorterOffsets      ; NZ after NC == "confirmed C"
        
        ld      a, (hl)                 ; reload bits
        inc     hl
        rla

        jr      c, ShorterOffsets

LongerOffets:
        ld      c, $fe

        add     a, a                    ; inline read gamma
        rl      c
        add     a, a
        jr      nc, $-4

        call    z, ReloadReadGamma

ProcessOffset:

        inc     c
        ret     z                       ; end-of-data marker (only checked for longer offsets)
        rr      c
        ld      b, c
        ld      c, (hl)
        inc     hl
        rr      c
        ld      (PrevOffset+1), bc

        ; lowest bit is the first bit of the gamma code for length
        jr      c, CopyMatch2

LongerMatch:
        ld      bc, 1

        add     a, a                    ; inline read gamma
        rl      c
        add     a, a
        jr      nc, $-4

        call    z,ReloadReadGamma

CopyMatch3:
        push    hl                      ; preserve source
        ld      hl, (PrevOffset+1)      ; restore offset
        add     hl, de                  ; HL = dest - offset

        ; because BC>=3-1, we can do 2 x LDI safely
        ldi
        ldir
        inc     c
        ldi
        pop     hl                      ; restore source

        ; after a match you can have either
        ; 0 + <elias length> = run of literals, or
        ; 1 + <elias offset msb> + [7-bits of offset lsb + 1-bit of length] + <elias length> = another match
AfterMatch3:
        add     a, a
        jr      c, UsualMatch

RunOfLiterals:
        inc     c
        add     a, a
        jr      nc, LongerRun
        jr      nz, CopyLiteral         ; NZ after NC == "confirmed C"
        
        ld      a, (hl)                 ; reload bits
        inc     hl
        rla

        jr      c, CopyLiteral

LongerRun:
        add     a, a                    ; inline read gamma
        rl      c
        add     a, a
        jr      nc, $-4

        jr      nz, CopyLiterals
        
        ld      a, (hl)                 ; reload bits
        inc     hl
        rla

        call    nc, ReadGammaAligned

CopyLiterals:
        ldi

CopyLiteral:
        ldir

        ; after a literal run you can have either
        ; 0 + <elias length> = match using a repeated offset, or
        ; 1 + <elias offset msb> + [7-bits of offset lsb + 1-bit of length] + <elias length> = another match
        add     a, a
        jr      c, UsualMatch

RepMatch:
        inc     c
        add     a, a
        jr      nc, LongerRepMatch
        jr      nz, CopyMatch1          ; NZ after NC == "confirmed C"

        ld      a, (hl)                 ; reload bits
        inc     hl
        rla

        jr      c, CopyMatch1

LongerRepMatch:
        add     a, a                    ; inline read gamma
        rl      c
        add     a, a
        jr      nc, $-4

        jp      nz, CopyMatch1

        ; this is a crafty equivalent of CALL ReloadReadGamma : JP CopyMatch1
        push    ix

        ;  the subroutine for reading the remainder of the partly read Elias gamma code.
        ;  it has two entry points: ReloadReadGamma first refills the bit reservoir in A,
        ;  while ReadGammaAligned assumes that the bit reservoir has just been refilled.
ReloadReadGamma:
        ld      a, (hl)                 ; reload bits
        inc     hl
        rla

        ret     c
ReadGammaAligned:
        add     a, a
        rl      c
        add     a, a
        ret     c
        add     a, a
        rl      c
        add     a, a
ReadingLongGamma:                       ; this loop does not need unrolling, as it does not get much use anyway
        ret     c
        add     a, a
        rl      c
        rl      b
        add     a, a
        jr      nz, ReadingLongGamma

        ld      a, (hl)                 ; reload bits
        inc     hl
        rla
        jr      ReadingLongGamma
