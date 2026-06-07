SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyboardShiftPressed, _keyboardSymbolShiftPressed
_keyboardShiftPressed: DB 0
_keyboardSymbolShiftPressed: DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _mouseTopLeft, joystickButtons
_mouseTopLeft: DW 0, 0, 0
joystickButtons: DB 0
mouseHwB: DW 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _mouseState
_mouseState:
stateHandled: DB 1
stateOngoing: DB 0
stateWheel:   DW 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC mouseSprite, _mouseX, _mouseY
mouseSprite:
         DB 127 ; index
_mouseX: DW 159 ; pos(coord.x)
_mouseY: DW 127 ; pos(coord.y)
         DW 0   ; pos(coord.z)
         DB 0   ; scaleUp
         DB 0   ; horizontalMirror
         DB 9   ; pattern

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GLOBAL joystickSpeedUp, joystickSpeedDown, joystickSpeedSlow, clampMouseX, clampMouseY

PUBLIC inputHandler
inputHandler:
    push af
    push de
    push hl

    ld hl, frameFlag    ; bump the frame counter so waitFrame can tell a real
    inc (hl)            ; ULA frame from a CTC wakeup once the audio timer runs

    ; buttons
    ld a, $fa
    in a, ($df) ; input from port $fadf
    ld (mouseHwB), a

.mouseKempstonX:
    ld de, 0 ; placeholder, also ensures D=0

    ld a, $fb
    in a, ($df) ; X from port $fbdf
    ld (mouseKempstonX+1), a ; store x for next time
    sub e ; subtract previousX
    ld l, a ; X - previousX = dx in L
    jp z, mouseKempstonY ; no change, move to next check

.lastMouseDirectionX: ; (!0)=left 0=right
    ld a, 0 ; placeholder
    ld e, a ; last mouse direction in E
    ld a, l ; dx in A for range check
    jp nc, mousePositiveX

.mouseNegativeX:
    cp $9c
    JP nc, mouseNegativeXSane ; within -100 <-> 0

    ; potential spike
    ld a, e ; last mouse direction X
    or a ; was previous direction left (non-zero)?
    jp z, mouseKempstonY ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mouseNegativeXSane:
    ld hl, (_mouseX)
    neg ; also clears carry
    ld e, a ; dx in E for subtracting
    sbc hl, de ; X - dx
    ld (_mouseX), hl
    ld (lastMouseDirectionX+1), a ; a will be non-zero here
    jp mouseKempstonY

.mousePositiveX:
    cp 99
    JP C, mousePositiveXSane ; within 0 <-> 100

    ; potential spike
    ld a, e ; last mouse direction X
    or a ; was previous direction right (zero)?
    jp nz, mouseKempstonY ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dx

.mousePositiveXSane
    ld hl, (_mouseX)
    add hl, a ; X + dx
    ld (_mouseX), hl
    xor a
    ld (lastMouseDirectionX+1), a

.mouseKempstonY:
    ld de, 0 ; placeholder, also ensures D=0

    ld a, $ff
    in a, ($df) ; Y from port $ffdf
    ld (mouseKempstonY+1), a ; store Y for next time
    sub e ; subtract previousY
    ld l, a ; Y - previousY = dy in HL
    jp z, joystickXSpeed ; no change, move to next check

.lastMouseDirectionY: ; (!0)=up 0=down
    ld a, 0 ; placeholder
    ld e, a ; last mouse direction in E
    ld a, l ; dy in A for later
    jp nc, mousePositiveY

    ; negative dy
    cp $9c
    JP nc, mouseNegativeYSane ; within -100 <-> 0

    ; potential spike
    ld a, e ; last mouse direction Y
    or a ; was previous direction up (non-zero)?
    jp z, joystickXSpeed ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mouseNegativeYSane:
    ld hl, (_mouseY)
    neg ; flip a for addition
    add hl, a ; Y + dy
    ld (_mouseY), hl
    ld (lastMouseDirectionY+1), a ; a will be non zero here
    jp joystickXSpeed

.mousePositiveY:
    cp 99
    JP C, mousePositiveYSane ; within 0 <-> 100

    ; potential spike
    ld a, e ; last mouse direction Y
    or a ; was previous direction down (zero)?
    jp nz, joystickXSpeed; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mousePositiveYSane:
    ld hl, (_mouseY)
    ld e, a ; dx in E for subtracting
    xor a ; zero and clear carry
    ld (lastMouseDirectionY+1), a
    sbc hl, de ; currentY - dy
    ld (_mouseY), hl

.joystickXSpeed:
    ld hl, 0 ; placeholder, load last X speed
    xor a
    in a, ($1f) ; input from port $001f
    rra
    jr c, joystickRight
    rra
    jr c, joystickLeft
    call joystickSpeedSlow ; no left or right, move HL back towards zero
    jp joystickXSpeedDone

.joystickLeft:
    call joystickSpeedDown
    jp joystickXSpeedDone

.joystickRight:
    call joystickSpeedUp
    rra ; no check for left
    ; fallthrough to joystickXSpeedDone

.joystickXSpeedDone:
    ld (joystickXSpeed+1), hl ; commit X speed for next loop
    ld de, (_mouseX)
    adc hl, de
    call clampMouseX ; updated mouse X using this speed, ok for HL and DE to get trashed

.joystickYSpeed:
    ld hl, 0 ; placeholder, load last Y speed

    rra
    jr c, joystickDown
    rra
    jr c, joystickUp
    call joystickSpeedSlow ; no up or down, move HL back to zero
    jp joystickYSpeedDone

.joystickUp:
    call joystickSpeedDown
    jp joystickYSpeedDone

.joystickDown:
    call joystickSpeedUp
    rra ; no check for up
    ; fallthrough to joystickYSpeedDone

.joystickYSpeedDone:
    ld (joystickYSpeed+1), hl ; store this Y speed for next loop
    ld de, (_mouseY)
    adc hl, de
    call clampMouseY ; updated mouse Y using this speed, ok for HL and DE to get trashed
    ; fallthrough to joystickFire

.joystickFire:
    ld(joystickButtons), a  ; xxxxxFFF
    and 7                   ; 00000FFF
    ld a, (mouseHwB)
    jp z, wheelHandler      ; flag from AND

    ; one of the fire buttons was pressed
    and $FD ; xxxxxx0x - pretend left button pressed
    ld (mouseHwB), a

.wheelHandler
    swapnib ; A = xxxxWWWW
    and $F  ; A = 0000WWWW

.updateMouseCurrentWheel:
    ld e, %00001111                   ; previousWheel, kemptston default is $F
    ld (updateMouseCurrentWheel+1), a ; previousWheel = wheel in A
    sub e                             ; wheelDiff = wheel in A - previousWheel in E

    or a                              ; set S flag, also clears C flag for addition
    ld d, 0
    ld e, a                           ; D = 0, E = A
    jp p, updateMouseStore
    dec d                             ; negative A (hence negative E), so let's make D a negative prefix ($FF)

.updateMouseStore
    ld hl, (stateWheel)
    add hl, de                        ; mouseState.wheel += wheelDiff
    ld (stateWheel), hl

    ld a, (stateOngoing)
    or a
    jp nz, updateMouseOngoing

    ld hl, (mouseHwB)
    bit 1, l
    jp nz, finish ; 1 = no click

    xor a
    ld (stateHandled), a ; 0
    inc a
    ld (stateOngoing), a ; 1

.updateMouseOngoing:
    ld hl, (mouseHwB)
    bit 1, l
    jp z, finish ; 0 = click still going

    xor a   ; clear
    ld (stateOngoing), a

.finish
    pop hl
    pop de
    pop af
    ei
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for the next ULA frame interrupt. Plain `halt` is no longer safe once the
; CTC audio timer runs (it wakes ~16000x/sec), so we halt in a loop until the
; ULA-driven frameFlag actually changes. Preserves all registers.

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
; The vector table must be 32-byte aligned AND always mapped. It lives in
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CTC channel 0 as the audio sample timer.
;
; CTC clock is a constant 28 MHz (unaffected by NextReg 0x07 / turbo). Timer
; mode, /16 prescaler, time constant 109 -> 28e6 / 16 / 109 = 16055 Hz (+0.34%
; of the 16000 Hz target).
;
; Channel 0 (port 0x183B), interrupt = NextReg 0xC5 bit0, IM2 vector slot 3.
; Matches the proven em00k/playwav32 setup (channels 0/1 are free for use).
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
