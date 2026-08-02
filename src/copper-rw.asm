SECTION code_compiler

; Always-mapped half of the copper module: just the group counters for the two
; kernels in copper-ro.asm. They are written every frame, so they cannot live in
; bank 28 alongside the code that uses them.

PUBLIC pf_count
pf_count:
    defb 0

PUBLIC ff_count
ff_count:
    defb 0
