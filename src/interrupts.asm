SECTION code_compiler

; Hardware IM2 interrupt setup, frame sync and the critical-section helpers.
; The ULA handler (inputHandler) lives in control-rw.asm and the CTC audio ISR
; (ctcAudioHandler) in ctc-rw.asm; this module wires them into the IM2 table.

GLOBAL inputHandler, ctcAudioHandler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for the next ULA frame interrupt. Plain `halt` is no longer safe once the
; CTC audio timer runs (it wakes ~16000x/sec), so we halt in a loop until the
; ULA-driven frameFlag actually changes. Preserves all registers.
; frameFlag is bumped by inputHandler (control-rw.asm) on each ULA frame.

PUBLIC frameFlag
frameFlag: DB 0

PUBLIC waitFrame, _waitFrame
waitFrame:
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disable interrupts for a critical section (e.g. esxdos calls page ROM over
; bank 28, which the ULA ISR calls into). Returns the prior IFF state so it can
; be restored without clobbering boot-time (interrupts-off) callers.

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hardware IM2 setup (Next core 3.02+).
;
; The vector table must be 256-byte aligned AND always mapped. It lives in
; code_compiler (0x8000+), which is never paged out - even during esxdos ROM
; paging (files.c pages ROM into 0x0000-0x3FFF only), so an interrupt during
; file I/O is harmless. Entries point straight at the handler, so the legacy
; 0x0038 trampoline in base.asm is no longer used.
;
; Source -> table slot (each slot 1 word): line=0, UART0/1 Rx=1,2,
; CTC channel 0..7 = 3..10, ULA frame = 11, UART0/1 Tx = 12,13.

im2Ignore:
    ei
    reti

; 512-byte buffer; the vector table is built at runtime on a genuine 256-byte
; boundary inside it (low byte forced to 0), so the IM2 base is simply I<<8 with
; NextReg 0xC0 bits 7-5 = 0 - no reliance on relocatable ALIGN or 0xC0[7:5].
im2buf:
    defs 512

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Switch from legacy IM1 to hardware IM2. Leaves interrupts DISABLED on exit
; (matching the rest of init); the caller's intrinsic_ei() turns them on.

PUBLIC _setupInterrupts
_setupInterrupts:
    di
    ; HL = next 256-byte boundary >= im2buf  (low byte 0)
    ld hl, im2buf
    ld a, l
    or a
    jr z, im2Aligned
    ld l, 0
    inc h
.im2Aligned:
    ; fill 16 word slots with im2Ignore
    push hl
    ld de, im2Ignore
    ld b, 16
.im2Fill:
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    djnz im2Fill
    pop hl
    ; slot 3 (byte 6) = CTC channel 0 handler
    push hl
    ld de, 6
    add hl, de
    ld de, ctcAudioHandler
    ld (hl), e
    inc hl
    ld (hl), d
    pop hl
    ; slot 11 (byte 22) = ULA frame handler
    push hl
    ld de, 22
    add hl, de
    ld de, inputHandler
    ld (hl), e
    inc hl
    ld (hl), d
    pop hl
    ; I = high byte of the 256-aligned table; base LSB = 0
    ld a, h
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
