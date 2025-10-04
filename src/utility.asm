SECTION code_compiler

PUBLIC _textBuf
_textBuf: DS 100

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

    pop de ; pattern in E
    ld d, e
    ld (stackClearSet+1), de

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

.stackClearSet:
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
