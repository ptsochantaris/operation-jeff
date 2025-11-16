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

PUBLIC _mouseSprite, _mouseX, _mouseY
_mouseSprite:
         DB 0 ; index
_mouseX: DW 0 ; pos(coord.x)
_mouseY: DW 0 ; pos(coord.y)
         DW 0 ; pos(coord.z)
         DB 0 ; scaleUp
         DB 0 ; horizontalMirror
         DB 0 ; pattern

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GLOBAL joystickSpeedUp, joystickSpeedDown, joystickSpeedSlow, clampMouseX, clampMouseY

PUBLIC inputHandler
inputHandler:
    push af
    push bc
    push de
    push hl

    ; buttons
    ld bc, $fadf
    in a, (c)
    ld (mouseHwB), a

.mouseKempstonX:
    ld de, 0 ; placeholder, also ensures D=0

    ld b, $fb
    in a, (c) ; X
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

    ld b, $ff
    in a, (c) ; Y
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
    pop bc
    pop af
    ei
    ret
