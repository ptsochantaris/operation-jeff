SECTION PAGE_28_POSTISR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC joystickSpeedSlow
joystickSpeedSlow:
    ex af, af'
    ld a, l
    or a
    jp z, joystickSpeedDone
    jp m, joystickSpeedUpNoSetup
    jp joystickSpeedDownNoSetup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC joystickSpeedUp
joystickSpeedUp:
    ex af, af'
    ld a, l
    ; fallthrough to joystickSpeedUpNoSetup
.joystickSpeedUpNoSetup:
    inc a
    jp m, joystickSpeedCommitNegative ; we're still below 0
    cp 5
    jp nc, joystickSpeedDone
    ld h, 0 ; commit is positive
    jp joystickSpeedCommit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC joystickSpeedDown
joystickSpeedDown:
    ex af, af'
    ld a, l
    ; fallthrough to joystickSpeedDownNoSetup
.joystickSpeedDownNoSetup:
    dec a
    jp m, joystickSpeedDownFromNegative
    ld h, 0 ; commit is positive
    jp joystickSpeedCommit

.joystickSpeedDownFromNegative:
    cp -5
    jp c, joystickSpeedDone
    ; fallthrough to joystickSpeedCommitNegative

.joystickSpeedCommitNegative:
    ld h, $FF ; l is negative, ensure we're negative all the way through in 16-bit
    ; fallthrough to joystickSpeedCommit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.joystickSpeedCommit:
    ld l, a
    ; fallthrough to joystickSpeedDone

.joystickSpeedDone:
    ex af, af'
    RET
