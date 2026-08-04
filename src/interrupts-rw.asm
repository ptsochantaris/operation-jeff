SECTION code_compiler

; Always-mapped half of the IM2 module: mutable interrupt state plus the
; critical-section helpers. The pure code (setup, frame wait, the ignore vector
; and the const vector-table template) lives in interrupts-ro.asm (bank 28).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; frameFlag - bumped by inputHandler (control-rw.asm) on each ULA frame; polled
; by waitFrame. Written from the ISR, so it must always be mapped.

PUBLIC frameFlag
frameFlag: DB 0

; Prior IFF state stashed by saveAndDisableInterrupts for restoreInterrupts to
; act on. Single slot, so critical sections must NOT nest: an inner save would
; see interrupts already off, overwrite this with 0, and the outer restore would
; then leave them off for good (hanging the next waitFrame).

interruptsNeedReEnabling: DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disable interrupts for a critical section (e.g. esxdos calls page ROM over
; bank 28, which the ULA ISR calls into). Stashes the prior IFF state so it can
; be restored without clobbering boot-time (interrupts-off) callers. Kept in the
; always-mapped section because it brackets the very window that displaces bank
; 28 - it must stay reachable while bank 28 is paged out.

PUBLIC _saveAndDisableInterrupts
_saveAndDisableInterrupts:
    ld a, i             ; P/V flag = IFF2 (1 if interrupts were enabled)
    jp pe, iff2Known    ; set -> unambiguously enabled
                        ; reset is ambiguous: the Z80 also clears P/V if an
                        ; interrupt is accepted during the ld a,i itself. Only
                        ; one can have landed (its ISR returns with IFF2 set
                        ; again), so a single retest settles it - and if
                        ; interrupts genuinely are off no ISR can run, so it
                        ; simply reads 0 a second time.
    ld a, i
.iff2Known:
    di
    ld a, 0             ; ld a,n leaves flags intact
    jp po, storeState   ; were disabled -> store 0
    inc a               ; were enabled -> store 1
.storeState:
    ld (interruptsNeedReEnabling), a
    ret

PUBLIC _restoreInterrupts
_restoreInterrupts:
    ld a, (interruptsNeedReEnabling)
    or a                ; was zero?
    ret z               ; if so, leave disabled
    ei
    ret
