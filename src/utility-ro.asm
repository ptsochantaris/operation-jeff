SECTION PAGE_28_POSTISR

; Read-only half of the utility module: pure code with no self-modifying
; operands and no mutable data, so it can live in bank 28. The rest (the text
; buffer and the self-modifying helpers - random16, writeNextReg, stackClear)
; stays in the always-mapped RW section in utility-rw.asm.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _copperAddress
_copperAddress:
    ld a, h
    or $C0
    nextreg	98, a ; REG_COPPER_CONTROL_H
    ld a, l
    nextreg	97, a ; REG_COPPER_CONTROL_L
    ret

PUBLIC _copperStop
_copperStop:
    nextreg	98, 0 ; REG_COPPER_CONTROL_H
    nextreg	97, 0 ; REG_COPPER_CONTROL_L
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; MMU3 ($6000-$7FFF) is shared - the tilemap window during gameplay, the palette
; decompressor's source slot, and the copper image's page - so anything that
; needs it for a moment borrows it and hands it straight back. The displaced page
; travels in the caller's own local, never a static here, so two borrows can nest
; without one clobbering the other's saved value.
;
; This is deliberately NOT what tilemap.c and bonus.c do. Those assert that page
; 10 is MMU3's resting state during gameplay and write it back by name, so they
; guarantee a value rather than preserving an unknown one. Do not unify them with
; this pair: it would quietly turn that guarantee into an assumption.
;
; Reading a Next register needs the port pair rather than the `nextreg` opcode:
; select on $243B, then read the value back from $253B - the same port with the
; high byte one higher, so `inc b` steps between them (as in graphics-ro.asm).

MMU3_REG equ $53

; byte mmu3Borrow(byte page) __z88dk_fastcall - page in L, previous page out in L
PUBLIC _mmu3Borrow
_mmu3Borrow:
    ld bc, $243B
    ld a, MMU3_REG
    out (c), a          ; select MMU3...
    inc b               ; ...and step to the data port at $253B
    in a, (c)           ; A = whatever page is mapped there now
    out (c), l          ; map the caller's page in its place
    ld l, a             ; and hand the old one back
    ret

; void mmu3Return(byte previous) __z88dk_fastcall - page in L
PUBLIC _mmu3Return
_mmu3Return:
    ld a, l
    nextreg MMU3_REG, a
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
