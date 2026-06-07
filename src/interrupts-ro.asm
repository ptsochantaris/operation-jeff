SECTION PAGE_28_POSTISR

; Read-only half of the IM2 module: pure code and const data, no mutable state,
; so it lives in pageable bank 28 to save the always-mapped code_compiler
; region. The mutable state (frameFlag, im2buf) and the critical-section helpers
; live in interrupts-rw.asm. Safe in bank 28 by the usual invariant: bank 28 is
; only ever paged out during esxdos calls (files.c), which run with interrupts
; disabled - so no interrupt fires, and _setupInterrupts/_waitFrame are only
; ever called while bank 28 is mapped (boot and normal gameplay respectively).
;
; The ULA handler (inputHandler) lives in control-rw.asm and the CTC audio ISR
; (ctcAudioHandler) in ctc-ro.asm; this module wires them into the IM2 table.

GLOBAL inputHandler, ctcAudioHandler   ; IM2 vector targets (other modules)
GLOBAL frameFlag, im2buf               ; mutable state (interrupts-rw.asm)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hardware IM2 setup (Next core 3.02+).
;
; The vector table must be 256-byte aligned AND always mapped. It lives in
; im2buf (code_compiler, interrupts-rw.asm), which is never paged out - even
; during esxdos ROM paging (files.c pages ROM into 0x0000-0x3FFF only), so an
; interrupt during file I/O is harmless. Entries point straight at the handler,
; so the legacy 0x0038 trampoline in base.asm is no longer used. The slot->source
; map is in the im2template definition below.

im2Ignore:
    ei
    reti

; Static template for the 16-word vector table. Every entry is a link-time
; label, so the whole table is constant; _setupInterrupts copies it onto the
; 256-aligned boundary inside im2buf at runtime. (A section-relative ALIGN
; can't guarantee absolute 256 alignment - the code_compiler section is not
; itself placed on a 256-byte boundary - hence the runtime boundary search.)
im2template:
    defw im2Ignore       ; 0  line
    defw im2Ignore       ; 1  UART0 Rx
    defw im2Ignore       ; 2  UART1 Rx
    defw ctcAudioHandler ; 3  CTC channel 0 (audio)
    defw im2Ignore       ; 4  CTC channel 1
    defw im2Ignore       ; 5  CTC channel 2
    defw im2Ignore       ; 6  CTC channel 3
    defw im2Ignore       ; 7  CTC channel 4
    defw im2Ignore       ; 8  CTC channel 5
    defw im2Ignore       ; 9  CTC channel 6
    defw im2Ignore       ; 10 CTC channel 7
    defw inputHandler    ; 11 ULA frame
    defw im2Ignore       ; 12 UART0 Tx
    defw im2Ignore       ; 13 UART1 Tx
    defw im2Ignore       ; 14 spare
    defw im2Ignore       ; 15 spare
im2templateEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Switch from legacy IM1 to hardware IM2. Leaves interrupts DISABLED on exit
; (matching the rest of init); the caller's intrinsic_ei() turns them on.

PUBLIC _setupInterrupts
_setupInterrupts:
    di
    ; DE = next 256-byte boundary >= im2buf (low byte 0); D is the table high byte
    ld de, im2buf
    ld a, e
    or a
    jr z, im2Aligned
    ld e, 0
    inc d
.im2Aligned:
    ld a, d              ; high byte -> I (set after the copy; ldir preserves A)
    ld hl, im2template
    ld bc, im2templateEnd - im2template
    ldir                 ; copy the constant template onto the aligned boundary
    ; I = high byte of the 256-aligned table; base LSB = 0
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
