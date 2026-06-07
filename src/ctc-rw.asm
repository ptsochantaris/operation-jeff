SECTION code_compiler

PUBLIC samplePtr, sampleStart, sampleEnd, sampleLoop, sampleTC

samplePtr:    DW 0
sampleStart:  DW 0
sampleEnd:    DW 0
sampleLoop:   DB 0
sampleTC:     DB 219      ; CTC time constant = per-effect playback rate (28MHz/16/TC)
