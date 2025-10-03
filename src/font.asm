SECTION PAGE_28_POSTISR

PUBLIC font_data
font_data:
	________ equ $00
	_______X equ $01
	______X_ equ $02
	______XX equ $03
	_____X__ equ $04
	_____X_X equ $05
	_____XX_ equ $06
	_____XXX equ $07
	____X___ equ $08
	____X__X equ $09
	____X_X_ equ $0A
	____X_XX equ $0B
	____XX__ equ $0C
	____XX_X equ $0D
	____XXX_ equ $0E
	____XXXX equ $0F
	___X____ equ $10
	___X___X equ $11
	___X__X_ equ $12
	___X__XX equ $13
	___X_X__ equ $14
	___X_X_X equ $15
	___X_XX_ equ $16
	___X_XXX equ $17
	___XX___ equ $18
	___XX__X equ $19
	___XX_X_ equ $1A
	___XX_XX equ $1B
	___XXX__ equ $1C
	___XXX_X equ $1D
	___XXXX_ equ $1E
	___XXXXX equ $1F
	__X_____ equ $20
	__X____X equ $21
	__X___X_ equ $22
	__X___XX equ $23
	__X__X__ equ $24
	__X__X_X equ $25
	__X__XX_ equ $26
	__X__XXX equ $27
	__X_X___ equ $28
	__X_X__X equ $29
	__X_X_X_ equ $2A
	__X_X_XX equ $2B
	__X_XX__ equ $2C
	__X_XX_X equ $2D
	__X_XXX_ equ $2E
	__X_XXXX equ $2F
	__XX____ equ $30
	__XX___X equ $31
	__XX__X_ equ $32
	__XX__XX equ $33
	__XX_X__ equ $34
	__XX_X_X equ $35
	__XX_XX_ equ $36
	__XX_XXX equ $37
	__XXX___ equ $38
	__XXX__X equ $39
	__XXX_X_ equ $3A
	__XXX_XX equ $3B
	__XXXX__ equ $3C
	__XXXX_X equ $3D
	__XXXXX_ equ $3E
	__XXXXXX equ $3F
	_X______ equ $40
	_X_____X equ $41
	_X____X_ equ $42
	_X____XX equ $43
	_X___X__ equ $44
	_X___X_X equ $45
	_X___XX_ equ $46
	_X___XXX equ $47
	_X__X___ equ $48
	_X__X__X equ $49
	_X__X_X_ equ $4A
	_X__X_XX equ $4B
	_X__XX__ equ $4C
	_X__XX_X equ $4D
	_X__XXX_ equ $4E
	_X__XXXX equ $4F
	_X_X____ equ $50
	_X_X___X equ $51
	_X_X__X_ equ $52
	_X_X__XX equ $53
	_X_X_X__ equ $54
	_X_X_X_X equ $55
	_X_X_XX_ equ $56
	_X_X_XXX equ $57
	_X_XX___ equ $58
	_X_XX__X equ $59
	_X_XX_X_ equ $5A
	_X_XX_XX equ $5B
	_X_XXX__ equ $5C
	_X_XXX_X equ $5D
	_X_XXXX_ equ $5E
	_X_XXXXX equ $5F
	_XX_____ equ $60
	_XX____X equ $61
	_XX___X_ equ $62
	_XX___XX equ $63
	_XX__X__ equ $64
	_XX__X_X equ $65
	_XX__XX_ equ $66
	_XX__XXX equ $67
	_XX_X___ equ $68
	_XX_X__X equ $69
	_XX_X_X_ equ $6A
	_XX_X_XX equ $6B
	_XX_XX__ equ $6C
	_XX_XX_X equ $6D
	_XX_XXX_ equ $6E
	_XX_XXXX equ $6F
	_XXX____ equ $70
	_XXX___X equ $71
	_XXX__X_ equ $72
	_XXX__XX equ $73
	_XXX_X__ equ $74
	_XXX_X_X equ $75
	_XXX_XX_ equ $76
	_XXX_XXX equ $77
	_XXXX___ equ $78
	_XXXX__X equ $79
	_XXXX_X_ equ $7A
	_XXXX_XX equ $7B
	_XXXXX__ equ $7C
	_XXXXX_X equ $7D
	_XXXXXX_ equ $7E
	_XXXXXXX equ $7F
	X_______ equ $80
	X______X equ $81
	X_____X_ equ $82
	X_____XX equ $83
	X____X__ equ $84
	X____X_X equ $85
	X____XX_ equ $86
	X____XXX equ $87
	X___X___ equ $88
	X___X__X equ $89
	X___X_X_ equ $8A
	X___X_XX equ $8B
	X___XX__ equ $8C
	X___XX_X equ $8D
	X___XXX_ equ $8E
	X___XXXX equ $8F
	X__X____ equ $90
	X__X___X equ $91
	X__X__X_ equ $92
	X__X__XX equ $93
	X__X_X__ equ $94
	X__X_X_X equ $95
	X__X_XX_ equ $96
	X__X_XXX equ $97
	X__XX___ equ $98
	X__XX__X equ $99
	X__XX_X_ equ $9A
	X__XX_XX equ $9B
	X__XXX__ equ $9C
	X__XXX_X equ $9D
	X__XXXX_ equ $9E
	X__XXXXX equ $9F
	X_X_____ equ $A0
	X_X____X equ $A1
	X_X___X_ equ $A2
	X_X___XX equ $A3
	X_X__X__ equ $A4
	X_X__X_X equ $A5
	X_X__XX_ equ $A6
	X_X__XXX equ $A7
	X_X_X___ equ $A8
	X_X_X__X equ $A9
	X_X_X_X_ equ $AA
	X_X_X_XX equ $AB
	X_X_XX__ equ $AC
	X_X_XX_X equ $AD
	X_X_XXX_ equ $AE
	X_X_XXXX equ $AF
	X_XX____ equ $B0
	X_XX___X equ $B1
	X_XX__X_ equ $B2
	X_XX__XX equ $B3
	X_XX_X__ equ $B4
	X_XX_X_X equ $B5
	X_XX_XX_ equ $B6
	X_XX_XXX equ $B7
	X_XXX___ equ $B8
	X_XXX__X equ $B9
	X_XXX_X_ equ $BA
	X_XXX_XX equ $BB
	X_XXXX__ equ $BC
	X_XXXX_X equ $BD
	X_XXXXX_ equ $BE
	X_XXXXXX equ $BF
	XX______ equ $C0
	XX_____X equ $C1
	XX____X_ equ $C2
	XX____XX equ $C3
	XX___X__ equ $C4
	XX___X_X equ $C5
	XX___XX_ equ $C6
	XX___XXX equ $C7
	XX__X___ equ $C8
	XX__X__X equ $C9
	XX__X_X_ equ $CA
	XX__X_XX equ $CB
	XX__XX__ equ $CC
	XX__XX_X equ $CD
	XX__XXX_ equ $CE
	XX__XXXX equ $CF
	XX_X____ equ $D0
	XX_X___X equ $D1
	XX_X__X_ equ $D2
	XX_X__XX equ $D3
	XX_X_X__ equ $D4
	XX_X_X_X equ $D5
	XX_X_XX_ equ $D6
	XX_X_XXX equ $D7
	XX_XX___ equ $D8
	XX_XX__X equ $D9
	XX_XX_X_ equ $DA
	XX_XX_XX equ $DB
	XX_XXX__ equ $DC
	XX_XXX_X equ $DD
	XX_XXXX_ equ $DE
	XX_XXXXX equ $DF
	XXX_____ equ $E0
	XXX____X equ $E1
	XXX___X_ equ $E2
	XXX___XX equ $E3
	XXX__X__ equ $E4
	XXX__X_X equ $E5
	XXX__XX_ equ $E6
	XXX__XXX equ $E7
	XXX_X___ equ $E8
	XXX_X__X equ $E9
	XXX_X_X_ equ $EA
	XXX_X_XX equ $EB
	XXX_XX__ equ $EC
	XXX_XX_X equ $ED
	XXX_XXX_ equ $EE
	XXX_XXXX equ $EF
	XXXX____ equ $F0
	XXXX___X equ $F1
	XXXX__X_ equ $F2
	XXXX__XX equ $F3
	XXXX_X__ equ $F4
	XXXX_X_X equ $F5
	XXXX_XX_ equ $F6
	XXXX_XXX equ $F7
	XXXXX___ equ $F8
	XXXXX__X equ $F9
	XXXXX_X_ equ $FA
	XXXXX_XX equ $FB
	XXXXXX__ equ $FC
	XXXXXX_X equ $FD
	XXXXXXX_ equ $FE
	XXXXXXXX equ $FF

;  32 $20 'space'
;  width 4, bbx 3, bby 4, bbw 1, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
;  33 $21 'exclam'
;  width 4, bbx 1, bby 0, bbw 1, bbh 5
	DB _X______
	DB _X______
	DB _X______
	DB ________
	DB _X______
	DB ________
;  34 $22 'quotedbl'
;  width 4, bbx 0, bby 3, bbw 3, bbh 2
	DB X_X_____
	DB X_X_____
	DB ________
	DB ________
	DB ________
	DB ________
;  35 $23 'numbersign'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB ________
;  36 $24 'dollar'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB _XX_____
	DB XX______
	DB _X______
	DB ________
;  37 $25 'percent'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB __X_____
	DB _X______
	DB X_______
	DB __X_____
	DB ________
;  38 $26 'ampersand'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB XX______
	DB XXX_____
	DB X_X_____
	DB _XX_____
	DB ________
;  39 $27 'quotesingle'
;  width 4, bbx 1, bby 3, bbw 1, bbh 2
	DB _X______
	DB _X______
	DB ________
	DB ________
	DB ________
	DB ________
;  40 $28 'parenleft'
;  width 4, bbx 1, bby 0, bbw 2, bbh 5
	DB __X_____
	DB _X______
	DB _X______
	DB _X______
	DB __X_____
	DB ________
;  41 $29 'parenright'
;  width 4, bbx 0, bby 0, bbw 2, bbh 5
	DB X_______
	DB _X______
	DB _X______
	DB _X______
	DB X_______
	DB ________
;  42 $2a 'asterisk'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB X_X_____
	DB _X______
	DB X_X_____
	DB ________
	DB ________
	DB ________
;  43 $2b 'plus'
;  width 4, bbx 0, bby 1, bbw 3, bbh 3
	DB ________
	DB _X______
	DB XXX_____
	DB _X______
	DB ________
	DB ________
;  44 $2c 'comma'
;  width 4, bbx 0, bby 0, bbw 2, bbh 2
	DB ________
	DB ________
	DB ________
	DB _X______
	DB X_______
	DB ________
;  45 $2d 'hyphen'
;  width 4, bbx 0, bby 2, bbw 3, bbh 1
	DB ________
	DB ________
	DB XXX_____
	DB ________
	DB ________
	DB ________
;  46 $2e 'period'
;  width 4, bbx 1, bby 0, bbw 1, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB _X______
	DB ________
;  47 $2f 'slash'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB __X_____
	DB _X______
	DB X_______
	DB X_______
	DB ________
;  48 $30 'zero'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB XX______
	DB ________
;  49 $31 'one'
;  width 4, bbx 0, bby 0, bbw 2, bbh 5
	DB _X______
	DB XX______
	DB _X______
	DB _X______
	DB _X______
	DB ________
;  50 $32 'two'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB __X_____
	DB _X______
	DB X_______
	DB XXX_____
	DB ________
;  51 $33 'three'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB __X_____
	DB _X______
	DB __X_____
	DB XX______
	DB ________
;  52 $34 'four'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB __X_____
	DB __X_____
	DB ________
;  53 $35 'five'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_______
	DB XX______
	DB __X_____
	DB XX______
	DB ________
;  54 $36 'six'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_______
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
;  55 $37 'seven'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB __X_____
	DB _X______
	DB X_______
	DB X_______
	DB ________
;  56 $38 'eight'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
;  57 $39 'nine'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB __X_____
	DB XX______
	DB ________
;  58 $3a 'colon'
;  width 4, bbx 1, bby 1, bbw 1, bbh 3
	DB ________
	DB _X______
	DB ________
	DB _X______
	DB ________
	DB ________
;  59 $3b 'semicolon'
;  width 4, bbx 0, bby 0, bbw 2, bbh 4
	DB ________
	DB _X______
	DB ________
	DB _X______
	DB X_______
	DB ________
;  60 $3c 'less'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _X______
	DB X_______
	DB _X______
	DB __X_____
	DB ________
;  61 $3d 'equal'
;  width 4, bbx 0, bby 1, bbw 3, bbh 3
	DB ________
	DB XXX_____
	DB ________
	DB XXX_____
	DB ________
	DB ________
;  62 $3e 'greater'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB _X______
	DB __X_____
	DB _X______
	DB X_______
	DB ________
;  63 $3f 'question'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB __X_____
	DB _X______
	DB ________
	DB _X______
	DB ________
;  64 $40 'at'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_X_____
	DB XXX_____
	DB X_______
	DB _XX_____
	DB ________
;  65 $41 'A'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB X_X_____
	DB ________
;  66 $42 'B'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB X_X_____
	DB XX______
	DB X_X_____
	DB XX______
	DB ________
;  67 $43 'C'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_______
	DB X_______
	DB X_______
	DB _XX_____
	DB ________
;  68 $44 'D'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB XX______
	DB ________
;  69 $45 'E'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_______
	DB XXX_____
	DB X_______
	DB XXX_____
	DB ________
;  70 $46 'F'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_______
	DB XXX_____
	DB X_______
	DB X_______
	DB ________
;  71 $47 'G'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_______
	DB XXX_____
	DB X_X_____
	DB _XX_____
	DB ________
;  72 $48 'H'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB X_X_____
	DB ________
;  73 $49 'I'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB _X______
	DB _X______
	DB _X______
	DB XXX_____
	DB ________
;  74 $4a 'J'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB __X_____
	DB __X_____
	DB X_X_____
	DB _X______
	DB ________
;  75 $4b 'K'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB XX______
	DB X_X_____
	DB X_X_____
	DB ________
;  76 $4c 'L'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB X_______
	DB X_______
	DB X_______
	DB XXX_____
	DB ________
;  77 $4d 'M'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB XXX_____
	DB XXX_____
	DB X_X_____
	DB X_X_____
	DB ________
;  78 $4e 'N'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB XXX_____
	DB XXX_____
	DB XXX_____
	DB X_X_____
	DB ________
;  79 $4f 'O'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB _X______
	DB ________
;  80 $50 'P'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB X_X_____
	DB XX______
	DB X_______
	DB X_______
	DB ________
;  81 $51 'Q'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB _XX_____
	DB ________
;  82 $52 'R'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB X_X_____
	DB XXX_____
	DB XX______
	DB X_X_____
	DB ________
;  83 $53 'S'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_______
	DB _X______
	DB __X_____
	DB XX______
	DB ________
;  84 $54 'T'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB _X______
	DB _X______
	DB _X______
	DB _X______
	DB ________
;  85 $55 'U'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
;  86 $56 'V'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB _X______
	DB _X______
	DB ________
;  87 $57 'W'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB XXX_____
	DB X_X_____
	DB ________
;  88 $58 'X'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB _X______
	DB X_X_____
	DB X_X_____
	DB ________
;  89 $59 'Y'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB _X______
	DB _X______
	DB _X______
	DB ________
;  90 $5a 'Z'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB __X_____
	DB _X______
	DB X_______
	DB XXX_____
	DB ________
;  91 $5b 'bracketleft'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB X_______
	DB X_______
	DB X_______
	DB XXX_____
	DB ________
;  92 $5c 'backslash'
;  width 4, bbx 0, bby 1, bbw 3, bbh 3
	DB ________
	DB X_______
	DB _X______
	DB __X_____
	DB ________
	DB ________
;  93 $5d 'bracketright'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB __X_____
	DB __X_____
	DB __X_____
	DB XXX_____
	DB ________
;  94 $5e 'asciicircum'
;  width 4, bbx 0, bby 3, bbw 3, bbh 2
	DB _X______
	DB X_X_____
	DB ________
	DB ________
	DB ________
	DB ________
;  95 $5f 'underscore'
;  width 4, bbx 0, bby 0, bbw 3, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB XXX_____
	DB ________
;  96 $60 'grave'
;  width 4, bbx 0, bby 3, bbw 2, bbh 2
	DB X_______
	DB _X______
	DB ________
	DB ________
	DB ________
	DB ________
;  97 $61 'a'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB XX______
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
;  98 $62 'b'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB XX______
	DB X_X_____
	DB X_X_____
	DB XX______
	DB ________
;  99 $63 'c'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB X_______
	DB X_______
	DB _XX_____
	DB ________
; 100 $64 'd'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _XX_____
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 101 $65 'e'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB X_X_____
	DB XX______
	DB _XX_____
	DB ________
; 102 $66 'f'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _X______
	DB XXX_____
	DB _X______
	DB _X______
	DB ________
; 103 $67 'g'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB __X_____
	DB _X______
; 104 $68 'h'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB XX______
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB ________
; 105 $69 'i'
;  width 4, bbx 1, bby 0, bbw 1, bbh 5
	DB _X______
	DB ________
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 106 $6a 'j'
;  width 4, bbx 0, bby -1, bbw 3, bbh 6
	DB __X_____
	DB ________
	DB __X_____
	DB __X_____
	DB X_X_____
	DB _X______
; 107 $6b 'k'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB X_X_____
	DB XX______
	DB XX______
	DB X_X_____
	DB ________
; 108 $6c 'l'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _X______
	DB _X______
	DB _X______
	DB XXX_____
	DB ________
; 109 $6d 'm'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB XXX_____
	DB XXX_____
	DB XXX_____
	DB X_X_____
	DB ________
; 110 $6e 'n'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB XX______
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB ________
; 111 $6f 'o'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _X______
	DB X_X_____
	DB X_X_____
	DB _X______
	DB ________
; 112 $70 'p'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB XX______
	DB X_X_____
	DB X_X_____
	DB XX______
	DB X_______
; 113 $71 'q'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB _XX_____
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB __X_____
; 114 $72 'r'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB X_______
	DB X_______
	DB X_______
	DB ________
; 115 $73 's'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB XX______
	DB _XX_____
	DB XX______
	DB ________
; 116 $74 't'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB XXX_____
	DB _X______
	DB _X______
	DB _XX_____
	DB ________
; 117 $75 'u'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 118 $76 'v'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB _X______
	DB ________
; 119 $77 'w'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB X_X_____
	DB XXX_____
	DB XXX_____
	DB XXX_____
	DB ________
; 120 $78 'x'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB X_X_____
	DB _X______
	DB _X______
	DB X_X_____
	DB ________
; 121 $79 'y'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB __X_____
	DB _X______
; 122 $7a 'z'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB XXX_____
	DB _XX_____
	DB XX______
	DB XXX_____
	DB ________
; 123 $7b 'braceleft'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB _X______
	DB X_______
	DB _X______
	DB _XX_____
	DB ________
; 124 $7c 'bar'
;  width 4, bbx 1, bby 0, bbw 1, bbh 5
	DB _X______
	DB _X______
	DB ________
	DB _X______
	DB _X______
	DB ________
; 125 $7d 'braceright'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _X______
	DB __X_____
	DB _X______
	DB XX______
	DB ________
; 126 $7e 'asciitilde'
;  width 4, bbx 0, bby 3, bbw 3, bbh 2
	DB _XX_____
	DB XX______
	DB ________
	DB ________
	DB ________
	DB ________
; 161 $a1 'exclamdown'
;  width 4, bbx 1, bby 0, bbw 1, bbh 5
	DB _X______
	DB ________
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 162 $a2 'cent'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB XXX_____
	DB X_______
	DB XXX_____
	DB _X______
	DB ________
; 163 $a3 'sterling'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB _X______
	DB XXX_____
	DB _X______
	DB XXX_____
	DB ________
; 164 $a4 'currency'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB _X______
	DB XXX_____
	DB _X______
	DB X_X_____
	DB ________
; 165 $a5 'yen'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB _X______
	DB XXX_____
	DB _X______
	DB ________
; 166 $a6 'brokenbar'
;  width 4, bbx 1, bby 0, bbw 1, bbh 5
	DB _X______
	DB _X______
	DB ________
	DB _X______
	DB _X______
	DB ________
; 167 $a7 'section'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB _X______
	DB X_X_____
	DB _X______
	DB XX______
	DB ________
; 168 $a8 'dieresis'
;  width 4, bbx 0, bby 4, bbw 3, bbh 1
	DB X_X_____
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
; 169 $a9 'copyright'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB _XX_____
	DB X_______
	DB _XX_____
	DB ________
	DB ________
	DB ________
; 170 $aa 'ordfeminine'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
	DB XXX_____
	DB ________
; 171 $ab 'guillemotleft'
;  width 4, bbx 0, bby 2, bbw 2, bbh 3
	DB _X______
	DB X_______
	DB _X______
	DB ________
	DB ________
	DB ________
; 172 $ac 'logicalnot'
;  width 4, bbx 0, bby 2, bbw 3, bbh 2
	DB ________
	DB XXX_____
	DB __X_____
	DB ________
	DB ________
	DB ________
; 173 $ad 'softhyphen'
;  width 4, bbx 0, bby 2, bbw 2, bbh 1
	DB ________
	DB ________
	DB XX______
	DB ________
	DB ________
	DB ________
; 174 $ae 'registered'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB XX______
	DB XX______
	DB X_X_____
	DB ________
	DB ________
	DB ________
; 175 $af 'macron'
;  width 4, bbx 0, bby 4, bbw 3, bbh 1
	DB XXX_____
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
; 176 $b0 'degree'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
	DB ________
	DB ________
; 177 $b1 'plusminus'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB XXX_____
	DB _X______
	DB ________
	DB XXX_____
	DB ________
; 178 $b2 'twosuperior'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB XX______
	DB _X______
	DB _XX_____
	DB ________
	DB ________
	DB ________
; 179 $b3 'threesuperior'
;  width 4, bbx 0, bby 2, bbw 3, bbh 3
	DB XXX_____
	DB _XX_____
	DB XXX_____
	DB ________
	DB ________
	DB ________
; 180 $b4 'acute'
;  width 4, bbx 1, bby 3, bbw 2, bbh 2
	DB __X_____
	DB _X______
	DB ________
	DB ________
	DB ________
	DB ________
; 181 $b5 'mu'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB X_X_____
	DB X_X_____
	DB XX______
	DB X_______
	DB ________
; 182 $b6 'paragraph'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_X_____
	DB _XX_____
	DB _XX_____
	DB _XX_____
	DB ________
; 183 $b7 'periodcentered'
;  width 4, bbx 0, bby 1, bbw 3, bbh 3
	DB ________
	DB XXX_____
	DB XXX_____
	DB XXX_____
	DB ________
	DB ________
; 184 $b8 'cedilla'
;  width 4, bbx 0, bby 0, bbw 3, bbh 3
	DB ________
	DB ________
	DB _X______
	DB __X_____
	DB XX______
	DB ________
; 185 $b9 'onesuperior'
;  width 4, bbx 1, bby 2, bbw 1, bbh 3
	DB _X______
	DB _X______
	DB _X______
	DB ________
	DB ________
	DB ________
; 186 $ba 'ordmasculine'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
	DB XXX_____
	DB ________
; 187 $bb 'guillemotright'
;  width 4, bbx 1, bby 2, bbw 2, bbh 3
	DB _X______
	DB __X_____
	DB _X______
	DB ________
	DB ________
	DB ________
; 188 $bc 'onequarter'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB X_______
	DB ________
	DB _XX_____
	DB __X_____
	DB ________
; 189 $bd 'onehalf'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB X_______
	DB ________
	DB XX______
	DB _XX_____
	DB ________
; 190 $be 'threequarters'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB XX______
	DB ________
	DB _XX_____
	DB __X_____
	DB ________
; 191 $bf 'questiondown'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB ________
	DB _X______
	DB X_______
	DB XXX_____
	DB ________
; 192 $c0 'Agrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB _X______
	DB XXX_____
	DB X_X_____
	DB ________
; 193 $c1 'Aacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB _X______
	DB XXX_____
	DB X_X_____
	DB ________
; 194 $c2 'Acircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB _X______
	DB XXX_____
	DB X_X_____
	DB ________
; 195 $c3 'Atilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB _X______
	DB XXX_____
	DB X_X_____
	DB ________
; 196 $c4 'Adieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB _X______
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB ________
; 197 $c5 'Aring'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB XX______
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB ________
; 198 $c6 'AE'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 199 $c7 'Ccedilla'
;  width 4, bbx 0, bby -1, bbw 3, bbh 6
	DB _XX_____
	DB X_______
	DB X_______
	DB _XX_____
	DB __X_____
	DB _X______
; 200 $c8 'Egrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 201 $c9 'Eacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 202 $ca 'Ecircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 203 $cb 'Edieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 204 $cc 'Igrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB XXX_____
	DB _X______
	DB XXX_____
	DB ________
; 205 $cd 'Iacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB XXX_____
	DB _X______
	DB XXX_____
	DB ________
; 206 $ce 'Icircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB XXX_____
	DB _X______
	DB XXX_____
	DB ________
; 207 $cf 'Idieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB XXX_____
	DB _X______
	DB XXX_____
	DB ________
; 208 $d0 'Eth'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB XX______
	DB ________
; 209 $d1 'Ntilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB ________
; 210 $d2 'Ograve'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 211 $d3 'Oacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 212 $d4 'Ocircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 213 $d5 'Otilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _XX_____
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 214 $d6 'Odieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 215 $d7 'multiply'
;  width 4, bbx 0, bby 1, bbw 3, bbh 3
	DB ________
	DB X_X_____
	DB _X______
	DB X_X_____
	DB ________
	DB ________
; 216 $d8 'Oslash'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB X_X_____
	DB XX______
	DB ________
; 217 $d9 'Ugrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB _X______
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB ________
; 218 $da 'Uacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _X______
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB ________
; 219 $db 'Ucircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB ________
; 220 $dc 'Udieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB X_X_____
	DB X_X_____
	DB XXX_____
	DB ________
; 221 $dd 'Yacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _X______
	DB X_X_____
	DB XXX_____
	DB _X______
	DB ________
; 222 $de 'Thorn'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB XXX_____
	DB X_X_____
	DB XXX_____
	DB X_______
	DB ________
; 223 $df 'germandbls'
;  width 4, bbx 0, bby -1, bbw 3, bbh 6
	DB _XX_____
	DB X_X_____
	DB XX______
	DB X_X_____
	DB XX______
	DB X_______
; 224 $e0 'agrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 225 $e1 'aacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 226 $e2 'acircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 227 $e3 'atilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 228 $e4 'adieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 229 $e5 'aring'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB _XX_____
	DB _XX_____
	DB X_X_____
	DB XXX_____
	DB ________
; 230 $e6 'ae'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB XXX_____
	DB XXX_____
	DB XX______
	DB ________
; 231 $e7 'ccedilla'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB _XX_____
	DB X_______
	DB _XX_____
	DB __X_____
	DB _X______
; 232 $e8 'egrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB _XX_____
	DB XXX_____
	DB _XX_____
	DB ________
; 233 $e9 'eacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB _XX_____
	DB XXX_____
	DB _XX_____
	DB ________
; 234 $ea 'ecircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB _XX_____
	DB XXX_____
	DB _XX_____
	DB ________
; 235 $eb 'edieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB _XX_____
	DB XXX_____
	DB _XX_____
	DB ________
; 236 $ec 'igrave'
;  width 4, bbx 1, bby 0, bbw 2, bbh 5
	DB _X______
	DB __X_____
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 237 $ed 'iacute'
;  width 4, bbx 0, bby 0, bbw 2, bbh 5
	DB _X______
	DB X_______
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 238 $ee 'icircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 239 $ef 'idieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB _X______
	DB _X______
	DB _X______
	DB ________
; 240 $f0 'eth'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB _XX_____
	DB X_X_____
	DB _XX_____
	DB ________
; 241 $f1 'ntilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _XX_____
	DB XX______
	DB X_X_____
	DB X_X_____
	DB ________
; 242 $f2 'ograve'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB __X_____
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
; 243 $f3 'oacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB X_______
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
; 244 $f4 'ocircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
; 245 $f5 'otilde'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XX______
	DB _XX_____
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
; 246 $f6 'odieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB _X______
	DB X_X_____
	DB _X______
	DB ________
; 247 $f7 'divide'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _X______
	DB ________
	DB XXX_____
	DB ________
	DB _X______
	DB ________
; 248 $f8 'oslash'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB XXX_____
	DB X_X_____
	DB XX______
	DB ________
; 249 $f9 'ugrave'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_______
	DB _X______
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 250 $fa 'uacute'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB __X_____
	DB _X______
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 251 $fb 'ucircumflex'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB XXX_____
	DB ________
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 252 $fc 'udieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB X_X_____
	DB X_X_____
	DB _XX_____
	DB ________
; 253 $fd 'yacute'
;  width 4, bbx 0, bby -1, bbw 3, bbh 6
	DB __X_____
	DB _X______
	DB X_X_____
	DB _XX_____
	DB __X_____
	DB _X______
; 254 $fe 'thorn'
;  width 4, bbx 0, bby -1, bbw 3, bbh 5
	DB ________
	DB X_______
	DB XX______
	DB X_X_____
	DB XX______
	DB X_______
; 255 $ff 'ydieresis'
;  width 4, bbx 0, bby -1, bbw 3, bbh 6
	DB X_X_____
	DB ________
	DB X_X_____
	DB _XX_____
	DB __X_____
	DB _X______
; 285 $11d 'gcircumflex'
;  width 6, bbx 0, bby 0, bbw 1, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
; 338 $152 'OE'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XX______
	DB XXX_____
	DB XX______
	DB _XX_____
	DB ________
; 339 $153 'oe'
;  width 4, bbx 0, bby 0, bbw 3, bbh 4
	DB ________
	DB _XX_____
	DB XXX_____
	DB XX______
	DB XXX_____
	DB ________
; 352 $160 'Scaron'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB _XX_____
	DB XX______
	DB _XX_____
	DB XX______
	DB ________
; 353 $161 'scaron'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB _XX_____
	DB XX______
	DB _XX_____
	DB XX______
	DB ________
; 376 $178 'Ydieresis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB ________
	DB X_X_____
	DB _X______
	DB _X______
	DB ________
; 381 $17d 'Zcaron'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB XXX_____
	DB _XX_____
	DB XX______
	DB XXX_____
	DB ________
; 382 $17e 'zcaron'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB X_X_____
	DB XXX_____
	DB _XX_____
	DB XX______
	DB XXX_____
	DB ________
; 3748 $ea4 'uni0EA4'
;  width 6, bbx 0, bby 0, bbw 1, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
; 5024 $13a0 'uni13A0'
;  width 6, bbx 0, bby 0, bbw 1, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
	DB ________
; 8226 $2022 'bullet'
;  width 4, bbx 1, bby 2, bbw 1, bbh 1
	DB ________
	DB ________
	DB _X______
	DB ________
	DB ________
	DB ________
; 8230 $2026 'ellipsis'
;  width 4, bbx 0, bby 0, bbw 3, bbh 1
	DB ________
	DB ________
	DB ________
	DB ________
	DB X_X_____
	DB ________
; 8364 $20ac 'Euro'
;  width 4, bbx 0, bby 0, bbw 3, bbh 5
	DB _XX_____
	DB XXX_____
	DB XXX_____
	DB XX______
	DB _XX_____
	DB ________
