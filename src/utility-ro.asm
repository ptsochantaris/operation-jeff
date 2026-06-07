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
