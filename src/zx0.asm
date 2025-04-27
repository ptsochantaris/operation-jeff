SECTION code_compiler

; ZX0 decompressor from here: https://github.com/einar-saukas/ZX0/blob/main/z80/dzx0_fast.asm
PUBLIC _decompressZX0
_decompressZX0:
        pop bc
        pop hl
        pop de
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
