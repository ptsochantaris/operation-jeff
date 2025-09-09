SECTION code_compiler

PUBLIC _mouseX
_mouseX: DW 0

PUBLIC _mouseY
_mouseY: DW 0

PUBLIC _mouseHwB
_mouseHwB: DW 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC mouseHandler
mouseHandler:
    ; buttons
    ld bc, $fadf
    in a, (c)
    ld (_mouseHwB), a

    ; mouse X update

mouseKempstonX:
    ld de, 0 ; previousX in E, D always zero

    ld b, $fb
    in a, (c) ; X
    ld (mouseKempstonX+1), a ; store x for next time
    ld l, a; X in HL
    xor a ; clear carry and zero
    ld h, a
    sbc hl, de ; X - previous = dx in L
    ld a, l ; dx in A for range check
    jp nc, mousePositiveVX

    cp $74
    JP C, mouseKempstonY ; ignore dx less than -100
    ld hl, (_mouseX)
    neg ; also clears carry
    ld e, a ; dx in E for subtracting
    sbc hl, de ; X - dx
    ld (_mouseX), hl
    jp mouseKempstonY

mousePositiveVX:
    cp 141
    JP NC, mouseKempstonY ; ignore dx greater than 120
    ld hl, (_mouseX)
    add hl, a ; X + dx
    ld (_mouseX), hl
    jp mouseKempstonY

    ; mouse Y update
mouseKempstonY:
    ld e, 0 ; previousY in E

    ld b, $ff
    in a, (c) ; Y
    ld (mouseKempstonY+1), a ; store Y for next time
    ld l, a; Y in HL
    xor a ; clear carry and zero
    ld h, a
    sbc hl, de ; Y - previousY = dy in HL
    ld a, l ; dy in A for later
    jp nc, mousePositiveVY

    cp $74
    ret c ; ignore dy less than -100
    ld hl, (_mouseY)
    neg ; flip a for addition
    add hl, a ; Y + dy
    ld (_mouseY), hl
    RET

mousePositiveVY:
    cp 141
    ret nc ; ignore dy greater than 120
    ld hl, (_mouseY)
    ld e, a ; dx in E for subtracting
    or a ; clear carry
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
