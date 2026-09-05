SECTION code_compiler

; Always-mapped half of the CTC audio module: the mutable sample state plus the
; ISR itself. The handler used to live in bank 28 alongside the rest of the
; player, but it is the most-executed code in the game (8000 interrupts/sec for
; zap/siren/menu-loop, 16000 for the sting), and moving it here lets it keep its
; hot state in its own operands - impossible in bank 28, where Layer 2
; write-through (configLayer2(1)) sends any store to VRAM instead of the code.
;
; Measured with z88dk-ticks: 183 -> 151 T-states per interrupt (17.5%), from
;   ld hl,(samplePtr)      16T -> ld hl,nn        10T  (pointer IS the operand)
;   ld bc,(sampleEnd)+cp c 24T -> cp n             7T  (end byte IS the operand)
;   ld a,(hl)/out/inc hl   25T -> outinb          16T  (Z80N; leaves B alone)
;
; The three SMC slots are PUBLIC because _startSample (ctc-ro.asm) primes them.
; Bank 28 writing into code_compiler like this is the same trick _print already
; uses for the glyph ink.

GLOBAL _sampleActive

PUBLIC sampleStart, sampleLoop, sampleTC

sampleStart:  DW 0
sampleLoop:   DB 0
sampleTC:     DB 219      ; CTC time constant = per-effect playback rate (28MHz/16/TC)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CTC channel 0 ISR: stream one PCM byte to the DAC, advance, loop or stop at
; the end. Wired into IM2 vector slot 3 by the table in base.asm.

COVOX_PORT equ 0xffdf      ; SpecDrum/covox DAC (same port the DMA used)

PUBLIC ctcAudioHandler, ctcPtr, ctcEndLo, ctcEndHi

ctcAudioHandler:
    push af
    push bc
    push hl

ctcPtr:
    ld hl, 0               ; SMC: the live sample pointer
    ld bc, COVOX_PORT
    outinb                 ; out (bc),(hl) then hl++ - B is NOT decremented, so
                           ; the $FF high half of the port survives
    ld (ctcPtr+1), hl

    ld a, l
ctcEndLo:
    cp 0                   ; SMC: low byte of the end address
    jr z, ctcCheckEnd      ; end of sample is 1-in-256 at best, so the hot path
                           ; falls through here (7t) instead of jumping (12t)
.ctcSampleDone:
    pop hl
    pop bc
    pop af
    ei
    reti

    ; cold tail: low byte matched, so check the high byte and handle the end.
    ; The pointer has already been stored by now, which is what the two exits
    ; below rely on: the non-end case just leaves, and the one-shot case leaves
    ; it parked one past the end (harmless - _startSample always re-primes it).
.ctcCheckEnd:
    ld a, h
ctcEndHi:
    cp 0                   ; SMC: high byte of the end address
    jr nz, ctcSampleDone
    ld a, (sampleLoop)
    or a
    jr z, ctcSampleEnd
    ld hl, (sampleStart)   ; looping sample: restart
    ld (ctcPtr+1), hl
    jr ctcSampleDone
.ctcSampleEnd:
    nextreg 0xC5, 0        ; one-shot done: stop the CTC interrupt
    xor a
    ld (_sampleActive), a
    jr ctcSampleDone
