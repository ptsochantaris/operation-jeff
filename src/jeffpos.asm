SECTION code_compiler

; void setJeffPos(struct jeff *restrict j, byte direction) __z88dk_callee __smallc
;
; Hand-written replacement for the C version (formerly in jeff.c). Mirrors it
; exactly. Called for every walking Jeff every logic tick, so it avoids the
; ix stack frame sdcc generated and leans on Z80N ops: `mul` for the heightmap
; row offset, `bsra` for the >>2 lookups, and `add hl,a` for the byte offsets.
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
    ld (sjp_flagJump+1), a  ; valid direction (0..3): jr displacement 0 => clamp

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
    jp sjp_loadX        ; jp: 10t, against 12t for an always-taken jr

.sjp_up:
    dec (iy+3)          ; --pos.y
    ld bc, 0x0A08       ; horizontal=8, vertical=10 (0x0A)
    jp sjp_loadX

.sjp_left:
    ld hl, (iy+1)
    dec hl
    dec hl              ; pos.x -= 2
    ld (iy+1), hl
    ld bc, 0x0E06       ; horizontal=6, vertical=14 (0x0E)
    jp sjp_lookup       ; HL already holds pos.x: skip the reload

.sjp_right:
    ld hl, (iy+1)
    inc hl
    inc hl              ; pos.x += 2
    ld (iy+1), hl
    ld bc, 0x0E06       ; horizontal=6, vertical=14 (0x0E)
    jp sjp_lookup       ; HL already holds pos.x: skip the reload

.sjp_noMove:
    ld a, sjp_setTarget - sjp_flagJump - 2
    ld (sjp_flagJump+1), a  ; direction 255: jr jumps => snap z to target
    ld bc, 0                ; horizontal & vertical = 0
    ; fall through

.sjp_loadX:
    ld hl, (iy+1)       ; HL = pos.x

.sjp_lookup:
    ; --- lookupX = (pos.x + horizontal) >> 2, lookupY = (pos.y + vertical) >> 2 ---
    ; (both arithmetic shifts; bsra leaves B alone, so one count serves both)
    ld a, b             ; A = horizontal
    add hl, a           ; HL = pos.x + horizontal  (Z80N add hl,a)
    ex de, hl           ; DE = pos.x + horizontal
    ld hl, (iy+3)       ; HL = pos.y
    ld a, c             ; A = vertical
    add hl, a           ; HL = pos.y + vertical
    ld b, 2
    bsra de, b          ; DE >>= 2
    ld a, e             ; A = lookupX (<= ~82); survives lookupY below
    ex de, hl           ; DE = pos.y + vertical
    bsra de, b          ; DE >>= 2  -> E = lookupY (<= 63)

    ; --- addr = _heightMap + lookupY*80 + lookupX ; targetZ = *addr ---
    ld d, e             ; D = lookupY
    ld e, 80
    mul d, e            ; DE = lookupY * 80   (Z80N)
    ld hl, _heightMap
    add hl, de
    add hl, a           ; + lookupX  (Z80N add hl,a)
    ld a, (hl)          ; A = targetZ (byte, 0..255)

    ; --- diff = targetZ - currentZ, computed once and reused by the clamp ---
    ld c, a             ; C = targetZ (survives the clamp arithmetic)
    ld de, (iy+5)       ; DE = currentZ (pos.z)
    ld h, 0
    ld l, a             ; HL = targetZ
    or a
    sbc hl, de          ; HL = diff (signed -255..255), DE = currentZ, Z if equal
    ret z               ; if (currentZ == targetZ) return;

.sjp_flagJump:          ; if (direction == 255) { pos.z = targetZ; return; }
    jr sjp_setTarget    ; displacement self-modified above: 0 => fall into clamp
                        ; MUST stay a jr - the patch above writes a jr displacement

.sjp_clamp:
    ld a, h
    or a
    jr z, sjp_diffPos   ; H==0 -> diff >= 0

    ; diff negative (H = 0xFF): diff < -2  <=>  L < 254
    ld a, l
    cp 254
    jr c, sjp_minus2
    jp sjp_setTarget    ; diff is -1 or -2

.sjp_diffPos:
    ; diff positive (H==0): diff > 2  <=>  L >= 3
    ld a, l
    cp 3
    jr nc, sjp_plus2
    ; fall through: diff is 1 or 2

.sjp_setTarget:
    ld (iy+5), c        ; pos.z = targetZ (high byte always 0)
    ld (iy+6), 0
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
