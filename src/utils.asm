SECTION code_compiler

PUBLIC _mouseX
_mouseX: DW 0

PUBLIC _mouseY
_mouseY: DW 0

PUBLIC _mouseHwB
_mouseHwB: DW 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lastMouseDirectionX: DB 0 ; (!0)=left 0=right
lastMouseDirectionY: DB 0 ; (!0)=up 0=down

PUBLIC mouseHandler
mouseHandler:
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
    ld a, l ; dy in A for later
    jp nc, mousePositiveY

    ; negative dy
    cp $9c
    JP nc, mouseNegativeYSane ; within -100 <-> 0

    ; potential spike
    ld a, (lastMouseDirectionY)
    or a ; was previous direction up (non-zero)?
    ret z ; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mouseNegativeYSane:
    ld hl, (_mouseY)
    neg ; flip a for addition
    add hl, a ; Y + dy
    ld (_mouseY), hl
    ld (lastMouseDirectionY), a ; a will be non zero here
    RET

.mousePositiveY:
    cp 99
    JP C, mousePositiveYSane ; within 0 <-> 100

    ; potential spike
    ld a, (lastMouseDirectionY)
    or a ; was previous direction down (zero)?
    ret nz; if not, it's a phase spike
    ld a, 255 ; correct for wrap spike
    sub l ; restore 255-dy

.mousePositiveYSane:    
    ld hl, (_mouseY)
    ld e, a ; dx in E for subtracting
    xor a ; zero and clear carry
    ld (lastMouseDirectionY), a
    sbc hl, de ; currentY - dy
    ld (_mouseY), hl
    RET

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
