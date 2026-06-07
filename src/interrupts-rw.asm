SECTION code_compiler

; Always-mapped half of the IM2 module: mutable interrupt state plus the
; critical-section helpers. The pure code (setup, frame wait, the ignore vector
; and the const vector-table template) lives in interrupts-ro.asm (bank 28).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; frameFlag - bumped by inputHandler (control-rw.asm) on each ULA frame; polled
; by waitFrame. Written from the ISR, so it must always be mapped.

PUBLIC frameFlag
frameFlag: DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disable interrupts for a critical section (e.g. esxdos calls page ROM over
; bank 28, which the ULA ISR calls into). Returns the prior IFF state so it can
; be restored without clobbering boot-time (interrupts-off) callers. Kept in the
; always-mapped section because it brackets the very window that displaces bank
; 28 - it must stay reachable while bank 28 is paged out.

PUBLIC _saveAndDisableInterrupts
_saveAndDisableInterrupts:
    ld a, i             ; P/V flag = IFF2 (1 if interrupts were enabled)
    di
    ld l, 1
    ret pe              ; were enabled -> return 1
    dec l               ; were disabled -> return 0
    ret

PUBLIC _restoreInterrupts ; L = prior state from saveAndDisableInterrupts
_restoreInterrupts:
    ld a, l
    or a
    ret z               ; were disabled - leave disabled
    ei
    ret
