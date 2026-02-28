SECTION PAGE_11
ORG $6000

    ; 0
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF

    ; 1
    DB $FF, $77, $77, $FF
    DB $FF, $71, $17, $FF
    DB $77, $71, $17, $77
    DB $71, $11, $11, $17
    DB $71, $11, $11, $17
    DB $77, $71, $17, $77
    DB $FF, $71, $17, $FF
    DB $FF, $77, $77, $FF

    ; 2
    DB $FF, $77, $77, $FF
    DB $FF, $72, $27, $FF
    DB $77, $72, $27, $77
    DB $72, $22, $22, $27
    DB $72, $22, $22, $27
    DB $77, $72, $27, $77
    DB $FF, $72, $27, $FF
    DB $FF, $77, $77, $FF

    ; 3
    DB $FF, $77, $77, $FF
    DB $FF, $70, $07, $FF
    DB $77, $70, $07, $77
    DB $70, $00, $00, $07
    DB $70, $00, $00, $07
    DB $77, $70, $07, $77
    DB $FF, $70, $07, $FF
    DB $FF, $77, $77, $FF

    ; 4 smartbomb
    DB $FF, $F7, $7F, $FF
    DB $FF, $74, $47, $FF
    DB $F7, $44, $44, $7F
    DB $74, $44, $44, $47
    DB $74, $44, $44, $47
    DB $F7, $44, $44, $7F
    DB $FF, $74, $47, $FF
    DB $FF, $F7, $7F, $FF

    ; 5 freeze
    DB $FF, $77, $77, $FF
    DB $F7, $88, $88, $7F
    DB $78, $87, $88, $87
    DB $78, $87, $88, $87
    DB $78, $87, $77, $87
    DB $78, $88, $88, $87
    DB $F7, $88, $88, $7F
    DB $FF, $77, $77, $FF

    ; 6 shots
    DB $FF, $77, $77, $FF
    DB $F7, $97, $99, $7F
    DB $79, $99, $79, $97
    DB $79, $97, $99, $97
    DB $79, $99, $79, $97
    DB $79, $97, $99, $97
    DB $F7, $99, $79, $7F
    DB $FF, $77, $77, $FF

    ; 7 slow movement
    DB $FF, $44, $44, $FF
    DB $F4, $45, $44, $4F
    DB $44, $45, $44, $44
    DB $44, $45, $44, $44
    DB $44, $45, $55, $44
    DB $44, $45, $54, $44
    DB $F4, $45, $44, $4F
    DB $FF, $44, $44, $FF

    ; 8 umbrella
    DB $FF, $77, $77, $FF
    DB $F7, $BB, $BB, $7F
    DB $7B, $B7, $7B, $B7
    DB $7B, $77, $77, $B7
    DB $7B, $BB, $BB, $B7
    DB $7B, $B7, $7B, $B7
    DB $F7, $BB, $BB, $7F
    DB $FF, $77, $77, $FF

    ; 9 invulnerable
    DB $F7, $77, $77, $7F
    DB $76, $66, $66, $67
    DB $76, $77, $77, $67
    DB $76, $73, $37, $67
    DB $76, $73, $37, $67
    DB $76, $77, $77, $67
    DB $76, $66, $66, $67
    DB $F7, $77, $77, $7F

    ; 10 range
    DB $FF, $77, $77, $FF
    DB $F7, $99, $99, $7F
    DB $79, $9A, $A9, $97
    DB $79, $A7, $7A, $97
    DB $79, $A7, $7A, $97
    DB $79, $9A, $A9, $97
    DB $F7, $99, $99, $7F
    DB $FF, $77, $77, $FF

    ; 11 zap
    DB $FF, $F7, $7F, $FF
    DB $FF, $79, $97, $FF
    DB $F7, $79, $97, $7F
    DB $79, $97, $79, $97
    DB $79, $97, $79, $97
    DB $F7, $79, $97, $7F
    DB $FF, $79, $97, $FF
    DB $FF, $F7, $7F, $FF

    ; 12 magnet
    DB $FF, $77, $77, $FF
    DB $F7, $55, $55, $7F
    DB $75, $55, $55, $57
    DB $75, $57, $75, $57
    DB $75, $57, $75, $57
    DB $75, $57, $75, $57
    DB $71, $17, $71, $17
    DB $F7, $77, $77, $7F

    ; 13 hollow plus dark
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF

    ; 14 hollow diamond dark
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF

    ; 15 hollow square dark
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $5F, $F5, $FF
    DB $FF, $F5, $5F, $FF
    DB $FF, $FF, $FF, $FF
    DB $FF, $FF, $FF, $FF

    ; 16 hollow plus medium
    DB $FF, $FF, $FF, $FF
    DB $FF, $66, $66, $FF
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $FF, $66, $66, $FF
    DB $FF, $FF, $FF, $FF

    ; 17 hollow diamond medium
    DB $FF, $FF, $FF, $FF
    DB $FF, $F6, $6F, $FF
    DB $FF, $6F, $F6, $FF
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $FF, $6F, $F6, $FF
    DB $FF, $F6, $6F, $FF
    DB $FF, $FF, $FF, $FF

    ; 18 hollow square medium
    DB $FF, $FF, $FF, $FF
    DB $FF, $66, $66, $FF
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $F6, $FF, $FF, $6F
    DB $FF, $66, $66, $FF
    DB $FF, $FF, $FF, $FF
    
    ; 19 hollow plus bright
    DB $FF, $77, $77, $FF
    DB $FF, $7F, $F7, $FF
    DB $77, $7F, $F7, $77
    DB $7F, $FF, $FF, $F7
    DB $7F, $FF, $FF, $F7
    DB $77, $7F, $F7, $77
    DB $FF, $7F, $F7, $FF
    DB $FF, $77, $77, $FF

    ; 20 hollow diamond bright
    DB $FF, $F7, $7F, $FF
    DB $FF, $7F, $F7, $FF
    DB $F7, $FF, $FF, $7F
    DB $7F, $FF, $FF, $F7
    DB $7F, $FF, $FF, $F7
    DB $F7, $FF, $FF, $7F
    DB $FF, $7F, $F7, $FF
    DB $FF, $F7, $7F, $FF

    ; 21 hollow square bright
    DB $FF, $77, $77, $FF
    DB $F7, $FF, $FF, $7F
    DB $7F, $FF, $FF, $F7
    DB $7F, $FF, $FF, $F7
    DB $7F, $FF, $FF, $F7
    DB $7F, $FF, $FF, $F7
    DB $F7, $FF, $FF, $7F
    DB $FF, $77, $77, $FF
