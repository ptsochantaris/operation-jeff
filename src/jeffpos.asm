SECTION code_compiler

; void setJeffPos(struct jeff *restrict j, byte direction) __z88dk_callee __smallc
;
; Hand-written replacement for the C version (formerly in jeff.c). Mirrors it
; exactly. Called for every walking Jeff every logic tick, so it avoids the
; ix stack frame sdcc generated and uses a single Z80N `mul` for the
; heightmap row offset instead of a chain of shift/adds.
;
; jeff struct layout (matches sprite_info + jeff fields):
;   +0  sprite.index (byte)
;   +1  sprite.pos.x (int16)
;   +3  sprite.pos.y (int16)
;   +5  sprite.pos.z (int16)
;   +7  sprite.scaleUp / +8 horizontalMirror / +9 pattern / +10 state ...
;
; __smallc pushes args left-to-right, __z88dk_callee cleans up:
;   stack on entry (top->down): [return][direction(16b, byte in low)][j]

EXTERN _heightMap

PUBLIC _setJeffPos
_setJeffPos:
    pop hl              ; return address
    pop de              ; E = direction (D = junk)
    pop iy              ; IY = j (clobberable: no __preserves_regs(iy))
    push hl             ; return address back on stack

    ; --- switch(direction): move pos, set B=horizontal, C=vertical, flag is255 ---
    ld a, e
    cp 4
    jr nc, sjp_noMove   ; direction >= 4 (i.e. 255) -> no move, zero offsets

    xor a
    ld (sjp_notEqual+1), a ; valid direction (0..3): patch flag check to "ld a,0"

    ld a, e
    or a
    jr z, sjp_left      ; 0 = LEFT
    dec a
    jr z, sjp_right     ; 1 = RIGHT
    dec a
    jr z, sjp_up        ; 2 = UP

                        ; else 3 = DOWN, fallthrough
    inc (iy+3)          ; ++pos.y
    ld bc, 0x1208       ; horizontal=8, vertical=18 (0x12)
    jr sjp_lookup

.sjp_up:
    dec (iy+3)          ; --pos.y
    ld bc, 0x0A08       ; horizontal=8, vertical=10 (0x0A)
    jr sjp_lookup

.sjp_left:
    ld hl, (iy+1)
    dec hl
    dec hl              ; pos.x -= 2
    ld (iy+1), hl
    ld bc, 0x0E06       ; horizontal=6, vertical=14 (0x0E)
    jr sjp_lookup

.sjp_right:
    ld hl, (iy+1)
    inc hl
    inc hl              ; pos.x += 2
    ld (iy+1), hl
    ld bc, 0x0E06       ; horizontal=6, vertical=14 (0x0E)
    jr sjp_lookup

.sjp_noMove:
    ld a, 1
    ld (sjp_notEqual+1), a  ; direction 255: patch flag check to "ld a,1" (snap z to target)
    ld bc, 0                ; horizontal & vertical = 0
    ; fall through

.sjp_lookup:
    ; --- lookupX = (pos.x + horizontal) >> 2  (arithmetic) ; kept in A ---
    ; (must precede lookupY: bsra needs its count in B, which holds horizontal)
    ld hl, (iy+1)       ; HL = pos.x
    ld a, b             ; A = horizontal
    add hl, a           ; HL = pos.x + horizontal  (Z80N add hl,a)
    ex de, hl           ; DE = pos.x + horizontal
    ld b, 2
    bsra de, b          ; DE >>= 2
    ld a, e             ; A = lookupX (<= ~82) ; survives lookupY below

    ; --- lookupY = (pos.y + vertical) >> 2 ; result in E ---
    ld hl, (iy+3)       ; HL = pos.y
    ld b, 0             ; BC = vertical (C still holds it); A is busy with lookupX
    add hl, bc          ; HL = pos.y + vertical
    ex de, hl           ; DE = pos.y + vertical
    ld b, 2
    bsra de, b          ; DE >>= 2  -> E = lookupY (<= ~68)

    ; --- addr = _heightMap + lookupY*80 + lookupX ; targetZ = *addr ---
    ld d, e             ; D = lookupY
    ld e, 80
    mul d, e            ; DE = lookupY * 80   (Z80N)
    ld hl, _heightMap
    add hl, de
    ld e, a             ; E = lookupX
    ld d, 0
    add hl, de          ; HL = address
    ld a, (hl)          ; A = targetZ (byte, 0..255)

    ; --- targetZ in BC (zero extended); currentZ in HL ---
    ld c, a
    ld b, 0             ; BC = targetZ
    
    ld hl, (iy+5)       ; HL = currentZ (pos.z)

    ; if (currentZ == targetZ) return;
    ld a, l
    cp c
    jr nz, sjp_notEqual
    ld a, h
    or a
    ret z

.sjp_notEqual:          ; if (direction == 255) { pos.z = targetZ; return; }
    ld a, 0             ; operand self-modified above: 0 => clamp, 1 => snap to target
    or a
    jr z, sjp_clamp
    ld (iy+5), bc       ; b = 0
    ret

.sjp_clamp:
    ; diff = targetZ - currentZ  (BC - HL)
    push hl             ; save currentZ
    ld hl, bc           ; HL = targetZ
    pop de              ; DE = currentZ
    or a
    sbc hl, de          ; HL = diff (signed, range -255..255), DE = currentZ
    ld a, h
    or a
    jr z, sjp_diffPos   ; H==0 -> diff >= 0

    ; diff negative (H = 0xFF): diff < -2  <=>  L < 254
    ld a, l
    cp 254
    jr c, sjp_minus2
    jr sjp_setTarget    ; diff is -1 or -2

.sjp_diffPos:
    ; diff positive (H==0): diff > 2  <=>  L >= 3
    ld a, l
    cp 3
    jr nc, sjp_plus2
    ; fall through: diff is 1 or 2

.sjp_setTarget:
    ld (iy+5), bc       ; pos.z = targetZ
    ret

.sjp_plus2:
    inc de              ; DE = currentZ
    inc de
    ld (iy+5), de       ; pos.z = currentZ + 2
    ret

.sjp_minus2:
    dec de              ; DE = currentZ
    dec de
    ld (iy+5), de       ; pos.z = currentZ - 2
    ret
