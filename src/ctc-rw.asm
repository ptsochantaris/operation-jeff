SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mutable CTC audio sample state, kept in the always-mapped code_compiler region
; (the player code itself lives in ctc-ro.asm / bank 28). Read/written by
; ctcAudioHandler at ~16kHz and by startSample; _sampleActive is also read from
; C. source/length are addresses within the sample's MMU1/MMU2 window, paged in
; by the caller (playSample, ctc.c).

PUBLIC samplePtr, sampleStart, sampleEnd, sampleLoop, sampleTC, _sampleActive

samplePtr:    DW 0
sampleStart:  DW 0
sampleEnd:    DW 0
sampleLoop:   DB 0
sampleTC:     DB 219      ; CTC time constant = per-effect playback rate (28MHz/16/TC)
_sampleActive: DB 0
