SECTION code_compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1 = the DMA controller still holds the copper transfer, so the per-frame copper
; upload can just LOAD+ENABLE instead of re-sending the whole program. Every DMA
; entry point in dma-ro.asm clears it (in dmaBegin) just before it programs the
; controller; the copper sets it after it primes. It says nothing about the
; copper's own layout - see copperLayoutResident in copper.c for that.
PUBLIC _copperDmaResident
_copperDmaResident: DB 0
