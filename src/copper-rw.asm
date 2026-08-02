SECTION code_compiler

EXTERN _random16

; void plasmaFill(byte *dst, byte *sine, word indices) __z88dk_callee __smallc
;
; Hand-written replacement for the inner loop of copperPlasmaUpdate (copper.c).
; Runs 288 times per cloud frame, so it is worth the asm: sdcc spent ~227 T-states
; per band, mostly on rebuilding a 16-bit table address three times over
; (`ld a,#lo / add / ld l,a / ld a,#hi / adc / ld h,a` = 33T a piece).
;
; The C side hands us page-aligned tables instead, which turns every lookup into
; `ld l,index` against a high byte that never changes:
;
;   sine    -> 256 entries, starts a page      (H holds its page for the whole run)
;   palette ->  64 entries, two pages up       (B holds its page, = sine page + 2)
;
; Register map for the run:
;   H  = sine page        L = scratch index
;   B  = palette page     C = scratch index
;   D  = ia (walks the sine table by GY_A = 3)
;   E  = ib (walks it by GY_B = 1)
;   IY = write cursor into the copper image (4-byte stride: one MOVE per band)
;   A  = scratch
;
; Unrolled 8 bands to a group so the cursor advance and the loop counter cost
; ~10T a band rather than ~50T; 288 bands = 36 groups exactly.
;
; __smallc pushes args left-to-right, __z88dk_callee cleans up:
;   stack on entry (top->down): [return][indices][sine][dst]

PLASMA_GROUPS equ 36        ; 288 bands / 8 per group

PUBLIC _plasmaFill
_plasmaFill:
    pop hl              ; return address
    pop de              ; D = ia, E = ib
    pop bc              ; BC = sine base; page-aligned so C = 0, B = its page
    ex (sp), hl         ; HL = dst, return address back on the stack

    push hl
    pop iy              ; IY = write cursor. sdcc never emits IY in this project
                        ; (IX is its frame pointer), so it needs no saving here -
                        ; same assumption jeffpos.asm and zx0.asm already make.

    ld h, b             ; H = sine page (fixed for the whole run)
    inc b
    inc b               ; B = palette page. The shared table block is laid out
                        ; sine / fire colour / palette, one page each, so the
                        ; palette sits two pages up - see copper.c.

    ld a, PLASMA_GROUPS
    ld (pf_count), a

.pf_group:
    ; --- one band: palette[sine[ia] + sine[ib]] -> *cursor -----------------
    ; sine values are 0..31, so the sum is 0..62 and always lands inside the
    ; 64-entry palette at the start of its page: C alone indexes it.
    ld l, d
    ld a, (hl)          ; sine[ia]
    ld l, e
    add a, (hl)         ; + sine[ib]
    ld c, a
    ld a, (bc)          ; palette[sum]
    ld (iy+0), a
    inc d
    inc d
    inc d               ; ia += 3
    inc e               ; ib += 1

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+4), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+8), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+12), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+16), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+20), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+24), a
    inc d
    inc d
    inc d
    inc e

    ld l, d
    ld a, (hl)
    ld l, e
    add a, (hl)
    ld c, a
    ld a, (bc)
    ld (iy+28), a
    inc d
    inc d
    inc d
    inc e

    ; --- next group: advance the cursor 8 bands, rebuild B, count down -----
    ld bc, 32           ; 8 bands x 4-byte stride
    add iy, bc
    ld a, h             ; palette page is always sine page + 2, so it costs
    inc a               ; nothing to keep: no spare register needed for it
    inc a
    ld b, a

    ld a, (pf_count)
    dec a
    ld (pf_count), a
    jr nz, pf_group

    ret

; Group counter. Lives here in code_compiler (main bank RAM, always mapped) for
; the same reason jeffpos.asm self-modifies there; plasmaFill is only ever called
; from the frame update, so a single static counter is safe.
.pf_count
    defb 0


; ---------------------------------------------------------------------------

; void fireFill(byte *dst, byte *colour, byte *buf) __z88dk_callee __smallc
;
; Replaces both per-frame fire loops at once: the upward heat propagation that
; was fireStep()'s second half, and the separate pass that turned each band's
; heat into a copper MOVE. They are fused - a band's colour is written the
; instant its new heat is known - which removes a whole second walk over the
; 144 bands.
;
; Only the colour table needs to be page-aligned; the heat buffer is walked as a
; plain pointer, so it stays wherever the linker puts it.
;
; Register map for the run:
;   HL = heat buffer walker, sitting on buf[i+1] at the top of each band
;   B  = colour table page   C = scratch (heat, then the colour index)
;   DE = the current random16 draw, spent 2 bits per band
;   IY = write cursor into the copper image (6-byte stride: WAIT + 2 MOVEs)
;   A  = scratch
;
; Bands are unrolled 8 to a group so each one can take its 2 random bits from a
; fixed slice of DE with no shifting at all, and so the cursor advance and loop
; counter cost ~8T a band rather than ~70T. That mirrors the C exactly: band k of
; a group used bits 2k..2k+1 of the draw, and a fresh draw arrives every 8 bands.
;
; 143 bands propagate (the bottom one keeps the seed fireSeed() just gave it, and
; is only drawn), so it is 17 groups of 8 plus a 7-band tail.
;
; __smallc pushes args left-to-right, __z88dk_callee cleans up:
;   stack on entry (top->down): [return][buf][colour][dst]

FIRE_GROUPS equ 17          ; 17 x 8 = 136 bands, then a 7-band tail

; One band: heat = max(buf[i+1] - cool, 0), stored back to buf[i] and drawn.
; `cool` is 3 when either of this band's two random bits is set, else 0 - the
; masks below walk DE two bits at a time. Both jr targets are `dec hl`: reached
; with A = below when there is no cooling, A = below - 3 when it does not
; underflow, and A = 0 when it would.
    MACRO fireBand rnd, mask, disp
    ld a, rnd
    and mask
    ld a, (hl)          ; below = buf[i+1]  (ld does not disturb the Z above)
    jr z, ASMPC+7       ; cool == 0 -> keep below
    sub 3
    jr nc, ASMPC+3      ; no underflow -> keep the difference
    xor a               ; clamp at 0
    dec hl              ; -> buf[i]
    ld (hl), a
    ld c, a             ; heat indexes the expanded colour ramp directly
    ld a, (bc)
    ld (iy+disp), a
    inc hl
    inc hl              ; -> buf[i+2]
    ENDM

PUBLIC _fireFill
_fireFill:
    pop hl              ; return address
    pop de              ; DE = heat buffer
    pop bc              ; BC = colour base; page-aligned so C = 0, B = its page
    ex (sp), hl         ; HL = dst, return address back on the stack

    push hl
    pop iy              ; IY = write cursor
    ex de, hl           ; HL = heat buffer (DE is about to be a random draw)
    inc hl              ; sit on buf[1]: every band reads i+1 and writes i

    ld a, FIRE_GROUPS
    ld (ff_count), a

.ff_group:
    push hl             ; random16 keeps BC/DE/IY, but returns in HL
    call _random16
    ld d, h
    ld e, l
    pop hl

    fireBand e, 0x03,  0
    fireBand e, 0x0C,  6
    fireBand e, 0x30, 12
    fireBand e, 0xC0, 18
    fireBand d, 0x03, 24
    fireBand d, 0x0C, 30
    fireBand d, 0x30, 36
    fireBand d, 0xC0, 42

    ld de, 48           ; 8 bands x 6-byte stride; DE is dead until the next draw
    add iy, de

    ld a, (ff_count)
    dec a
    ld (ff_count), a
    jp nz, ff_group     ; the group body is ~180 bytes: out of jr range (and jp
                        ; is 10T against a taken jr's 12T anyway)

    ; --- tail: the last 7 propagating bands share one more draw --------------
    push hl
    call _random16
    ld d, h
    ld e, l
    pop hl

    fireBand e, 0x03,  0
    fireBand e, 0x0C,  6
    fireBand e, 0x30, 12
    fireBand e, 0xC0, 18
    fireBand d, 0x03, 24
    fireBand d, 0x0C, 30
    fireBand d, 0x30, 36

    ; --- bottom band: never propagated, just drawn from its fresh seed -------
    dec hl              ; -> buf[FIRE_BANDS - 1]
    ld c, (hl)
    ld a, (bc)
    ld (iy+42), a
    ret

; Group counter; see the note on pf_count above.
.ff_count
    defb 0
