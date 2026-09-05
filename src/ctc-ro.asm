SECTION PAGE_28_POSTISR

; CTC audio sample player - the pure code half (no self-modification of its own,
; no data), so it lives in bank 28 to save the always-mapped code_compiler
; region. The mutable sample state AND the ISR live in ctc-rw.asm: the handler
; self-modifies, which bank 28 cannot do (Layer 2 write-through would send the
; store to VRAM), and it is hot enough to be worth the always-mapped bytes.
; The routines here are only called from mainline code with bank 28 mapped.
;
; CTC channel 0 timer recipe (see interrupts-ro.asm for the IM2 wiring):
; CTC clock is a constant 28 MHz (unaffected by NextReg 0x07 / turbo). Timer
; mode, /16 prescaler -> rate = 28e6 / 16 / TC. Channel 0 (port 0x183B),
; interrupt = NextReg 0xC5 bit0, IM2 vector slot 3. Matches em00k/playwav32.
;
; Control word 0x85 = %1000 0101:
;   b7=1 interrupt enable   b6=0 timer mode      b5=0 /16 prescaler
;   b4=0 edge (n/a)         b3=0 auto-trigger    b2=1 time constant follows
;   b1=0 NO reset           b0=1 control word
; NOTE: setting b1 (software reset) holds the channel reset on the Next so it
; never counts. Both the channel's own b7 AND NextReg 0xC5 bit0 must be set for
; the interrupt to reach the Z80 in IM2 mode.

GLOBAL sampleStart, sampleLoop, sampleTC, _sampleActive
GLOBAL ctcPtr, ctcEndLo, ctcEndHi      ; the ISR's SMC slots (ctc-rw.asm)

CTC_AUDIO_CHANNEL equ 0x183b

PUBLIC _startSample
_startSample:
    pop hl                ; return address
    pop bc                ; loop (in C)
    pop de                ; time constant (in E)
    ld a, e
    ld (sampleTC), a      ; the ISR never reads this, so it is safe to set early
    pop de                ; length
    ex (sp), hl           ; HL = source, return address back on stack

    ; Everything below is state the ISR reads, so it goes up under di. A sample
    ; already playing would otherwise slip an interrupt between these stores and
    ; write its own (stale) pointer over the new one.
    di
    ld a, c
    ld (sampleLoop), a
    ld (ctcPtr+1), hl     ; prime the handler's pointer operand
    ld (sampleStart), hl
    add hl, de            ; end = source + length
    ld a, l
    ld (ctcEndLo+1), a    ; ...and the two halves of its end compare
    ld a, h
    ld (ctcEndHi+1), a
    ld a, 1
    ld (_sampleActive), a
    ld bc, CTC_AUDIO_CHANNEL
    ld a, 0x85            ; timer, /16, int enable, TC follows, no reset
    out (c), a
    ld a, (sampleTC)      ; per-effect rate (28MHz/16/TC)
    out (c), a
    nextreg 0xC5, 1       ; enable CTC channel 0 interrupt
    ei
    ret

PUBLIC _stopAudioTimer
_stopAudioTimer:
    nextreg 0xC5, 0      ; mask CTC channel 0 interrupt
    ld bc, CTC_AUDIO_CHANNEL
    ld a, 0x03           ; control word + software reset (halts the channel)
    out (c), a
    xor a
    ld (_sampleActive), a
    ret
