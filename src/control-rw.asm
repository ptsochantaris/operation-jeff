SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _mouseX, _mouseY, _mouseHwB, joystickButtons
_mouseX: DW 0
_mouseY: DW 0
_mouseHwB: DW 2
joystickButtons: DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GLOBAL joystickSpeedUp, joystickSpeedDown, joystickSpeedSlow

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
    ld h, a ; fast zero for H
    sbc hl, de ; X - previous = dx in L
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
    ld e, 0 ; placeholder

    ld b, $ff
    in a, (c) ; Y
    ld (mouseKempstonY+1), a ; store Y for next time
    ld l, a; Y in HL
    xor a ; clear carry and zero
    ld h, a
    sbc hl, de ; Y - previousY = dy in HL
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
    ld bc, $001F
    in a, (c)
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
    ld (_mouseX), hl

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
    ld (_mouseY), hl ; updated mouse Y using this speed
    ; fallthrough to joystickFire

.joystickFire:
    ld(joystickButtons), a  ; xxxxxFFF
    and 7                   ; 00000FFF
    ret z

    ; one of the fire buttons was pressed
    ld a, (_mouseHwB)
    and $FD ; xxxxxx0x - pretend left button pressed
    ld (_mouseHwB), a
    ret
