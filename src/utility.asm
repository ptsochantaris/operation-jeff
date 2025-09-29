SECTION code_compiler

PUBLIC _textBuf
_textBuf: DS 100

PUBLIC _mouseX
_mouseX: DW 0

PUBLIC _mouseY
_mouseY: DW 0

PUBLIC _mouseHwB
_mouseHwB: DW 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC joystickButtons
joystickButtons: DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lastMouseDirectionX: DB 0 ; (!0)=left 0=right
lastMouseDirectionY: DB 0 ; (!0)=up 0=down

PUBLIC inputHandler
inputHandler:
    ; buttons
    ld bc, $fadf
    in a, (c)
    ld (_mouseHwB), a

.mouseKempstonX:
    ld de, 0 ; d always stays zero

    ld b, $fb
    in a, (c) ; X
    ld (mouseKempstonX+1), a ; store x for next time
    ld l, a; X in HL
    xor a ; clear carry and zero
    ld h, a
    sbc hl, de ; X - previous = dx in L
    jp z, mouseKempstonY ; no change, move to next check
    ld a, l ; dx in A for range check
    jp nc, mousePositiveX

    ; negative dx
    cp $9c
    JP nc, mouseNegativeXSane ; within -100 <-> 0

    ; potential spike
    ld a, (lastMouseDirectionX)
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
    ld (lastMouseDirectionX), a ; a will be non-zero here
    jp mouseKempstonY

.mousePositiveX:
    cp 99
    JP C, mousePositiveXSane ; within 0 <-> 100

    ; potential spike
    ld a, (lastMouseDirectionX)
    or a ; was previous direction right (zero)?
    jp nz, mouseKempstonY ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dx

.mousePositiveXSane
    ld hl, (_mouseX)
    add hl, a ; X + dx
    ld (_mouseX), hl
    xor a
    ld (lastMouseDirectionX), a

.mouseKempstonY:
    ld e, 0

    ld b, $ff
    in a, (c) ; Y
    ld (mouseKempstonY+1), a ; store Y for next time
    ld l, a; Y in HL
    xor a ; clear carry and zero
    ld h, a
    sbc hl, de ; Y - previousY = dy in HL
    jp z, joystickHorizontal ; no change, move to next check
    ld a, l ; dy in A for later
    jp nc, mousePositiveY

    ; negative dy
    cp $9c
    JP nc, mouseNegativeYSane ; within -100 <-> 0

    ; potential spike
    ld a, (lastMouseDirectionY)
    or a ; was previous direction up (non-zero)?
    jp z, joystickHorizontal ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mouseNegativeYSane:
    ld hl, (_mouseY)
    neg ; flip a for addition
    add hl, a ; Y + dy
    ld (_mouseY), hl
    ld (lastMouseDirectionY), a ; a will be non zero here
    jp joystickHorizontal

.mousePositiveY:
    cp 99
    JP C, mousePositiveYSane ; within 0 <-> 100

    ; potential spike
    ld a, (lastMouseDirectionY)
    or a ; was previous direction down (zero)?
    jp nz, joystickHorizontal; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mousePositiveYSane:
    ld hl, (_mouseY)
    ld e, a ; dx in E for subtracting
    xor a ; zero and clear carry
    ld (lastMouseDirectionY), a
    sbc hl, de ; currentY - dy
    ld (_mouseY), hl

.joystickHorizontal:
    ld hl, (joystickXSpeed+2) ; prepare for X speed

    ld bc, $001F
    in a, (c)
    rra
    jr c, joystickRight
    rra
    jr c, joystickLeft
    call joystickSpeedSlow ; no left or right, move HL back towards zero
    jp joystickVertical

.joystickLeft:
    call joystickSpeedDown
    jp joystickVertical

.joystickRight:
    call joystickSpeedUp
    rra ; no check for left

.joystickVertical:
    ld (joystickXSpeed+2), hl ; commit X speed
    ld hl, (joystickYSpeed+2) ; prepare for Y speed

    rra
    jr c, joystickDown
    rra
    jr c, joystickUp
    call joystickSpeedSlow ; no up or down, move HL back to zero
    jp joystickFire

.joystickUp:
    call joystickSpeedDown
    jp joystickFire

.joystickDown:
    call joystickSpeedUp
    rra ; no check for up

.joystickFire:
    ld (joystickYSpeed+2), hl ; commit Y speed

    ld(joystickButtons), a
    and 7   ; 00000FFF
    jr z, joystickCommit

    ; one of the fire buttons was pressed
    ld a, (_mouseHwB)
    and $FD ; xxxxxx0x - pretend left button pressed
    ld (_mouseHwB), a
    ; fallthrough to joystickCommit

.joystickCommit:
    ld de, (_mouseX)
.joystickXSpeed:
    add de, 0 ; placeholder
    ld (_mouseX), de

    ld de, (_mouseY)
.joystickYSpeed:
    add de, 0 ; placeholder
    ld (_mouseY), de
    RET

.joystickSpeedUp:
    ex af, af'
    ld a, l
    ; fallthrough to joystickSpeedUpNoSetup

.joystickSpeedUpNoSetup:
    inc a
    jp m, joystickSpeedCommitNegative
    cp 5
    jp nc, joystickSpeedDone
    ; fallthrough to joystickSpeedCommitPositive

.joystickSpeedCommitPositive:
    ld h, 0
    ld l, a
    ex af, af'
    RET

.joystickSpeedDown:
    ex af, af'
    ld a, l
    ; fallthrough to joystickSpeedDownNoSetup

.joystickSpeedDownNoSetup:
    dec a
    jp m, joystickSpeedDownFromNegative
    jp joystickSpeedCommitPositive

.joystickSpeedDownFromNegative:
    cp -5
    jp c, joystickSpeedDone
    ; fallthrough to joystickSpeedCommitNegative

.joystickSpeedCommitNegative:
    ld h, $FF
    ld l, a
    ; fallthrough to joystickSpeedDone

.joystickSpeedDone:
    ex af, af'
    RET

.joystickSpeedSlow:
    ex af, af'
    ld a, l
    or a
    jp z, joystickSpeedDone
    jp m, joystickSpeedUpNoSetup
    jp joystickSpeedDownNoSetup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; from the brilliant guide here: http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html

PUBLIC _random16
_random16:
    ld hl,1       ; seed must not be 0
    ld a,h
    rra
    ld a,l
    rra
    xor h
    ld h,a
    ld a,l
    rra
    ld a,h
    rra
    xor l
    ld l,a
    xor h
    ld h,a
    ld (_random16+1),hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _writeNextReg
_writeNextReg:
    pop hl ; return address
    
    pop bc ; len in c
    ld b, c ; will use b to loop for length
    
    pop de ; pointer

    ex (sp), hl ; register in l, return address back on stack
    ld a, l
    ld (writeNextRegSet+2), a ; store the register we'll be writing to

writeNextRegLoop:
    ld a, (de)
    inc de
writeNextRegSet:
    NEXTREG 0, a
    djnz writeNextRegLoop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _stackClear
_stackClear:
    DI

    pop hl ; return address
    pop de ; len
    ex (sp), hl ; base, return address back on stack

    ld (stackClearSp+1), sp

    add hl, de ; add len
    ld sp, hl ; (final address + 1)

    ld b, 1
    BSRL de, b ; divide len by two

    ; from: https://www.cpcwiki.eu/index.php/Programming:Filling_memory_with_a_byte
    ld b, e    ; This method takes advantage of the fact that DJNZ leaves B as 0, which subsequent DJNZs see as 256
    dec de     ; B = (length/2) MOD 256, so 0 = a 512-byte block
    inc d      ; D = the number of 512-byte blocks to write, or just = 1 if the length is <512

    ld hl, 0 ; byte to push

.stackClearLoop:
    push hl
    djnz stackClearLoop
    dec d
    jp nz, stackClearLoop

.stackClearSp:
    ld SP, 0 ; placeholder
    EI
    RET
