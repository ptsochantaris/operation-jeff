SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CTC channel 0 as the audio sample timer.
;
; CTC clock is a constant 28 MHz (unaffected by NextReg 0x07 / turbo). Timer
; mode, /16 prescaler, time constant 109 -> 28e6 / 16 / 109 = 16055 Hz (+0.34%
; of the 16000 Hz target).
;
; Channel 0 (port 0x183B), interrupt = NextReg 0xC5 bit0, IM2 vector slot 3
; (the table is built in interrupts.asm). Matches em00k/playwav32.
;
; Control word 0x85 = %1000 0101:
;   b7=1 interrupt enable   b6=0 timer mode      b5=0 /16 prescaler
;   b4=0 edge (n/a)         b3=0 auto-trigger    b2=1 time constant follows
;   b1=0 NO reset           b0=1 control word
; NOTE: setting b1 (software reset) holds the channel reset on the Next so it
; never counts - that was why it wouldn't fire. Both the channel's own b7 AND
; NextReg 0xC5 bit0 must be set for the interrupt to reach the Z80 in IM2 mode.

CTC_AUDIO_CHANNEL equ 0x183b
COVOX_PORT        equ 0xffdf      ; SpecDrum/covox DAC (same port the DMA used)

; Sample playback state, read by ctcAudioHandler at ~16kHz. source/length are
; addresses within the sample's MMU1/MMU2 window, paged in by the caller.
samplePtr:    DW 0
sampleStart:  DW 0
sampleEnd:    DW 0
sampleLoop:   DB 0
sampleTC:     DB 219      ; CTC time constant = per-effect playback rate (28MHz/16/TC)
PUBLIC _sampleActive
_sampleActive: DB 0

; void startSample(word source, word length, byte tc, byte loop) __z88dk_callee __smallc
PUBLIC _startSample
_startSample:
    pop hl                ; return address
    pop de                ; loop (in E)
    ld a, e
    ld (sampleLoop), a
    pop de                ; time constant (in E)
    ld a, e
    ld (sampleTC), a
    pop de                ; length
    ex (sp), hl           ; HL = source, return address back on stack
    ld (samplePtr), hl
    ld (sampleStart), hl
    add hl, de            ; end = source + length
    ld (sampleEnd), hl
    di
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CTC channel 0 ISR (~16kHz): stream one PCM byte to the DAC, advance, loop or
; stop at the end. Replaces what the DMA used to do, but off the DMA controller.
; Wired into IM2 vector slot 3 by _setupInterrupts (interrupts.asm).

PUBLIC ctcAudioHandler
ctcAudioHandler:
    push af
    push bc
    push hl
    ld hl, (samplePtr)
    ld a, (hl)             ; next sample byte
    ld bc, COVOX_PORT
    out (c), a             ; -> DAC
    inc hl
    ld bc, (sampleEnd)
    ld a, l
    cp c
    jr nz, ctcSampleStore
    ld a, h
    cp b
    jr nz, ctcSampleStore
    ; reached end of sample
    ld a, (sampleLoop)
    or a
    jr z, ctcSampleEnd
    ld hl, (sampleStart)   ; looping sample: restart
    jr ctcSampleStore
.ctcSampleEnd:
    nextreg 0xC5, 0        ; one-shot done: stop the CTC interrupt
    xor a
    ld (_sampleActive), a
    jr ctcSampleDone
.ctcSampleStore:
    ld (samplePtr), hl
.ctcSampleDone:
    pop hl
    pop bc
    pop af
    ei
    reti
