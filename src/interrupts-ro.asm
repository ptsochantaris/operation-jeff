SECTION PAGE_28_POSTISR

GLOBAL frameFlag                       ; mutable state (interrupts-rw.asm)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for the next ULA frame interrupt. Plain `halt` is no longer safe once the
; CTC audio timer runs (it wakes ~16000x/sec), so we halt in a loop until the
; ULA-driven frameFlag actually changes. Preserves all registers.

PUBLIC _waitFrame
_waitFrame:
    push af
    push hl
    ld hl, frameFlag
    ld a, (hl)
.waitFrameLoop:
    halt
    cp (hl)
    jr z, waitFrameLoop
    pop hl
    pop af
    ret

PUBLIC _setupInterrupts
_setupInterrupts:
    xor a
    ld i, a
    nextreg 0xC0, 9      ; HW IM2 (b0) + stackless (b3); vector LSB high bits = 0
    nextreg 0xC4, 1      ; enable ULA frame interrupt
    nextreg 0xC5, 0      ; CTC channel interrupts off (armed later)
    nextreg 0xC6, 0      ; UART interrupts off
    nextreg 0xC8, 0xFF   ; clear pending ULA/line status
    nextreg 0xC9, 0xFF   ; clear pending CTC status
    nextreg 0xCA, 0xFF   ; clear pending UART status
    nextreg 0xCC, 0      ; no DMA-interrupt routing
    nextreg 0xCD, 0
    nextreg 0xCE, 0
    im 2
    ret
