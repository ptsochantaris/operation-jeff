// Created from bdf2c Version 4, (c) 2009, 2010 by Lutz Sammer

#include "resources.h"

#define ________ 0x00
#define _______X 0x01
#define ______X_ 0x02
#define ______XX 0x03
#define _____X__ 0x04
#define _____X_X 0x05
#define _____XX_ 0x06
#define _____XXX 0x07
#define ____X___ 0x08
#define ____X__X 0x09
#define ____X_X_ 0x0A
#define ____X_XX 0x0B
#define ____XX__ 0x0C
#define ____XX_X 0x0D
#define ____XXX_ 0x0E
#define ____XXXX 0x0F
#define ___X____ 0x10
#define ___X___X 0x11
#define ___X__X_ 0x12
#define ___X__XX 0x13
#define ___X_X__ 0x14
#define ___X_X_X 0x15
#define ___X_XX_ 0x16
#define ___X_XXX 0x17
#define ___XX___ 0x18
#define ___XX__X 0x19
#define ___XX_X_ 0x1A
#define ___XX_XX 0x1B
#define ___XXX__ 0x1C
#define ___XXX_X 0x1D
#define ___XXXX_ 0x1E
#define ___XXXXX 0x1F
#define __X_____ 0x20
#define __X____X 0x21
#define __X___X_ 0x22
#define __X___XX 0x23
#define __X__X__ 0x24
#define __X__X_X 0x25
#define __X__XX_ 0x26
#define __X__XXX 0x27
#define __X_X___ 0x28
#define __X_X__X 0x29
#define __X_X_X_ 0x2A
#define __X_X_XX 0x2B
#define __X_XX__ 0x2C
#define __X_XX_X 0x2D
#define __X_XXX_ 0x2E
#define __X_XXXX 0x2F
#define __XX____ 0x30
#define __XX___X 0x31
#define __XX__X_ 0x32
#define __XX__XX 0x33
#define __XX_X__ 0x34
#define __XX_X_X 0x35
#define __XX_XX_ 0x36
#define __XX_XXX 0x37
#define __XXX___ 0x38
#define __XXX__X 0x39
#define __XXX_X_ 0x3A
#define __XXX_XX 0x3B
#define __XXXX__ 0x3C
#define __XXXX_X 0x3D
#define __XXXXX_ 0x3E
#define __XXXXXX 0x3F
#define _X______ 0x40
#define _X_____X 0x41
#define _X____X_ 0x42
#define _X____XX 0x43
#define _X___X__ 0x44
#define _X___X_X 0x45
#define _X___XX_ 0x46
#define _X___XXX 0x47
#define _X__X___ 0x48
#define _X__X__X 0x49
#define _X__X_X_ 0x4A
#define _X__X_XX 0x4B
#define _X__XX__ 0x4C
#define _X__XX_X 0x4D
#define _X__XXX_ 0x4E
#define _X__XXXX 0x4F
#define _X_X____ 0x50
#define _X_X___X 0x51
#define _X_X__X_ 0x52
#define _X_X__XX 0x53
#define _X_X_X__ 0x54
#define _X_X_X_X 0x55
#define _X_X_XX_ 0x56
#define _X_X_XXX 0x57
#define _X_XX___ 0x58
#define _X_XX__X 0x59
#define _X_XX_X_ 0x5A
#define _X_XX_XX 0x5B
#define _X_XXX__ 0x5C
#define _X_XXX_X 0x5D
#define _X_XXXX_ 0x5E
#define _X_XXXXX 0x5F
#define _XX_____ 0x60
#define _XX____X 0x61
#define _XX___X_ 0x62
#define _XX___XX 0x63
#define _XX__X__ 0x64
#define _XX__X_X 0x65
#define _XX__XX_ 0x66
#define _XX__XXX 0x67
#define _XX_X___ 0x68
#define _XX_X__X 0x69
#define _XX_X_X_ 0x6A
#define _XX_X_XX 0x6B
#define _XX_XX__ 0x6C
#define _XX_XX_X 0x6D
#define _XX_XXX_ 0x6E
#define _XX_XXXX 0x6F
#define _XXX____ 0x70
#define _XXX___X 0x71
#define _XXX__X_ 0x72
#define _XXX__XX 0x73
#define _XXX_X__ 0x74
#define _XXX_X_X 0x75
#define _XXX_XX_ 0x76
#define _XXX_XXX 0x77
#define _XXXX___ 0x78
#define _XXXX__X 0x79
#define _XXXX_X_ 0x7A
#define _XXXX_XX 0x7B
#define _XXXXX__ 0x7C
#define _XXXXX_X 0x7D
#define _XXXXXX_ 0x7E
#define _XXXXXXX 0x7F
#define X_______ 0x80
#define X______X 0x81
#define X_____X_ 0x82
#define X_____XX 0x83
#define X____X__ 0x84
#define X____X_X 0x85
#define X____XX_ 0x86
#define X____XXX 0x87
#define X___X___ 0x88
#define X___X__X 0x89
#define X___X_X_ 0x8A
#define X___X_XX 0x8B
#define X___XX__ 0x8C
#define X___XX_X 0x8D
#define X___XXX_ 0x8E
#define X___XXXX 0x8F
#define X__X____ 0x90
#define X__X___X 0x91
#define X__X__X_ 0x92
#define X__X__XX 0x93
#define X__X_X__ 0x94
#define X__X_X_X 0x95
#define X__X_XX_ 0x96
#define X__X_XXX 0x97
#define X__XX___ 0x98
#define X__XX__X 0x99
#define X__XX_X_ 0x9A
#define X__XX_XX 0x9B
#define X__XXX__ 0x9C
#define X__XXX_X 0x9D
#define X__XXXX_ 0x9E
#define X__XXXXX 0x9F
#define X_X_____ 0xA0
#define X_X____X 0xA1
#define X_X___X_ 0xA2
#define X_X___XX 0xA3
#define X_X__X__ 0xA4
#define X_X__X_X 0xA5
#define X_X__XX_ 0xA6
#define X_X__XXX 0xA7
#define X_X_X___ 0xA8
#define X_X_X__X 0xA9
#define X_X_X_X_ 0xAA
#define X_X_X_XX 0xAB
#define X_X_XX__ 0xAC
#define X_X_XX_X 0xAD
#define X_X_XXX_ 0xAE
#define X_X_XXXX 0xAF
#define X_XX____ 0xB0
#define X_XX___X 0xB1
#define X_XX__X_ 0xB2
#define X_XX__XX 0xB3
#define X_XX_X__ 0xB4
#define X_XX_X_X 0xB5
#define X_XX_XX_ 0xB6
#define X_XX_XXX 0xB7
#define X_XXX___ 0xB8
#define X_XXX__X 0xB9
#define X_XXX_X_ 0xBA
#define X_XXX_XX 0xBB
#define X_XXXX__ 0xBC
#define X_XXXX_X 0xBD
#define X_XXXXX_ 0xBE
#define X_XXXXXX 0xBF
#define XX______ 0xC0
#define XX_____X 0xC1
#define XX____X_ 0xC2
#define XX____XX 0xC3
#define XX___X__ 0xC4
#define XX___X_X 0xC5
#define XX___XX_ 0xC6
#define XX___XXX 0xC7
#define XX__X___ 0xC8
#define XX__X__X 0xC9
#define XX__X_X_ 0xCA
#define XX__X_XX 0xCB
#define XX__XX__ 0xCC
#define XX__XX_X 0xCD
#define XX__XXX_ 0xCE
#define XX__XXXX 0xCF
#define XX_X____ 0xD0
#define XX_X___X 0xD1
#define XX_X__X_ 0xD2
#define XX_X__XX 0xD3
#define XX_X_X__ 0xD4
#define XX_X_X_X 0xD5
#define XX_X_XX_ 0xD6
#define XX_X_XXX 0xD7
#define XX_XX___ 0xD8
#define XX_XX__X 0xD9
#define XX_XX_X_ 0xDA
#define XX_XX_XX 0xDB
#define XX_XXX__ 0xDC
#define XX_XXX_X 0xDD
#define XX_XXXX_ 0xDE
#define XX_XXXXX 0xDF
#define XXX_____ 0xE0
#define XXX____X 0xE1
#define XXX___X_ 0xE2
#define XXX___XX 0xE3
#define XXX__X__ 0xE4
#define XXX__X_X 0xE5
#define XXX__XX_ 0xE6
#define XXX__XXX 0xE7
#define XXX_X___ 0xE8
#define XXX_X__X 0xE9
#define XXX_X_X_ 0xEA
#define XXX_X_XX 0xEB
#define XXX_XX__ 0xEC
#define XXX_XX_X 0xED
#define XXX_XXX_ 0xEE
#define XXX_XXXX 0xEF
#define XXXX____ 0xF0
#define XXXX___X 0xF1
#define XXXX__X_ 0xF2
#define XXXX__XX 0xF3
#define XXXX_X__ 0xF4
#define XXXX_X_X 0xF5
#define XXXX_XX_ 0xF6
#define XXXX_XXX 0xF7
#define XXXXX___ 0xF8
#define XXXXX__X 0xF9
#define XXXXX_X_ 0xFA
#define XXXXX_XX 0xFB
#define XXXXXX__ 0xFC
#define XXXXXX_X 0xFD
#define XXXXXXX_ 0xFE
#define XXXXXXXX 0xFF

const byte font_data[] = {
//  32 $20 'space'
//	width 4, bbx 3, bby 4, bbw 1, bbh 1
	________,
	________,
	________,
	________,
	________,
	________,
//  33 $21 'exclam'
//	width 4, bbx 1, bby 0, bbw 1, bbh 5
	_X______,
	_X______,
	_X______,
	________,
	_X______,
	________,
//  34 $22 'quotedbl'
//	width 4, bbx 0, bby 3, bbw 3, bbh 2
	X_X_____,
	X_X_____,
	________,
	________,
	________,
	________,
//  35 $23 'numbersign'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	X_X_____,
	XXX_____,
	X_X_____,
	________,
//  36 $24 'dollar'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	_XX_____,
	XX______,
	_X______,
	________,
//  37 $25 'percent'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	__X_____,
	_X______,
	X_______,
	__X_____,
	________,
//  38 $26 'ampersand'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	XX______,
	XXX_____,
	X_X_____,
	_XX_____,
	________,
//  39 $27 'quotesingle'
//	width 4, bbx 1, bby 3, bbw 1, bbh 2
	_X______,
	_X______,
	________,
	________,
	________,
	________,
//  40 $28 'parenleft'
//	width 4, bbx 1, bby 0, bbw 2, bbh 5
	__X_____,
	_X______,
	_X______,
	_X______,
	__X_____,
	________,
//  41 $29 'parenright'
//	width 4, bbx 0, bby 0, bbw 2, bbh 5
	X_______,
	_X______,
	_X______,
	_X______,
	X_______,
	________,
//  42 $2a 'asterisk'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	X_X_____,
	_X______,
	X_X_____,
	________,
	________,
	________,
//  43 $2b 'plus'
//	width 4, bbx 0, bby 1, bbw 3, bbh 3
	________,
	_X______,
	XXX_____,
	_X______,
	________,
	________,
//  44 $2c 'comma'
//	width 4, bbx 0, bby 0, bbw 2, bbh 2
	________,
	________,
	________,
	_X______,
	X_______,
	________,
//  45 $2d 'hyphen'
//	width 4, bbx 0, bby 2, bbw 3, bbh 1
	________,
	________,
	XXX_____,
	________,
	________,
	________,
//  46 $2e 'period'
//	width 4, bbx 1, bby 0, bbw 1, bbh 1
	________,
	________,
	________,
	________,
	_X______,
	________,
//  47 $2f 'slash'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	__X_____,
	_X______,
	X_______,
	X_______,
	________,
//  48 $30 'zero'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_X_____,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  49 $31 'one'
//	width 4, bbx 0, bby 0, bbw 2, bbh 5
	_X______,
	XX______,
	_X______,
	_X______,
	_X______,
	________,
//  50 $32 'two'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	__X_____,
	_X______,
	X_______,
	XXX_____,
	________,
//  51 $33 'three'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	__X_____,
	_X______,
	__X_____,
	XX______,
	________,
//  52 $34 'four'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	XXX_____,
	__X_____,
	__X_____,
	________,
//  53 $35 'five'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_______,
	XX______,
	__X_____,
	XX______,
	________,
//  54 $36 'six'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_______,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
//  55 $37 'seven'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	__X_____,
	_X______,
	X_______,
	X_______,
	________,
//  56 $38 'eight'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_X_____,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
//  57 $39 'nine'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_X_____,
	XXX_____,
	__X_____,
	XX______,
	________,
//  58 $3a 'colon'
//	width 4, bbx 1, bby 1, bbw 1, bbh 3
	________,
	_X______,
	________,
	_X______,
	________,
	________,
//  59 $3b 'semicolon'
//	width 4, bbx 0, bby 0, bbw 2, bbh 4
	________,
	_X______,
	________,
	_X______,
	X_______,
	________,
//  60 $3c 'less'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_X______,
	X_______,
	_X______,
	__X_____,
	________,
//  61 $3d 'equal'
//	width 4, bbx 0, bby 1, bbw 3, bbh 3
	________,
	XXX_____,
	________,
	XXX_____,
	________,
	________,
//  62 $3e 'greater'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	_X______,
	__X_____,
	_X______,
	X_______,
	________,
//  63 $3f 'question'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	__X_____,
	_X______,
	________,
	_X______,
	________,
//  64 $40 'at'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_X_____,
	XXX_____,
	X_______,
	_XX_____,
	________,
//  65 $41 'A'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
//  66 $42 'B'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	X_X_____,
	XX______,
	X_X_____,
	XX______,
	________,
//  67 $43 'C'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_______,
	X_______,
	X_______,
	_XX_____,
	________,
//  68 $44 'D'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  69 $45 'E'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_______,
	XXX_____,
	X_______,
	XXX_____,
	________,
//  70 $46 'F'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_______,
	XXX_____,
	X_______,
	X_______,
	________,
//  71 $47 'G'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_______,
	XXX_____,
	X_X_____,
	_XX_____,
	________,
//  72 $48 'H'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
//  73 $49 'I'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	_X______,
	_X______,
	_X______,
	XXX_____,
	________,
//  74 $4a 'J'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	__X_____,
	__X_____,
	X_X_____,
	_X______,
	________,
//  75 $4b 'K'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	XX______,
	X_X_____,
	X_X_____,
	________,
//  76 $4c 'L'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	X_______,
	X_______,
	X_______,
	XXX_____,
	________,
//  77 $4d 'M'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	X_X_____,
	________,
//  78 $4e 'N'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	XXX_____,
	XXX_____,
	X_X_____,
	________,
//  79 $4f 'O'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	________,
//  80 $50 'P'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	X_X_____,
	XX______,
	X_______,
	X_______,
	________,
//  81 $51 'Q'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	_XX_____,
	________,
//  82 $52 'R'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	X_X_____,
	XXX_____,
	XX______,
	X_X_____,
	________,
//  83 $53 'S'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_______,
	_X______,
	__X_____,
	XX______,
	________,
//  84 $54 'T'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	_X______,
	_X______,
	_X______,
	_X______,
	________,
//  85 $55 'U'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
//  86 $56 'V'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	X_X_____,
	_X______,
	_X______,
	________,
//  87 $57 'W'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	XXX_____,
	XXX_____,
	X_X_____,
	________,
//  88 $58 'X'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	_X______,
	X_X_____,
	X_X_____,
	________,
//  89 $59 'Y'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	_X______,
	_X______,
	_X______,
	________,
//  90 $5a 'Z'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	__X_____,
	_X______,
	X_______,
	XXX_____,
	________,
//  91 $5b 'bracketleft'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	X_______,
	X_______,
	X_______,
	XXX_____,
	________,
//  92 $5c 'backslash'
//	width 4, bbx 0, bby 1, bbw 3, bbh 3
	________,
	X_______,
	_X______,
	__X_____,
	________,
	________,
//  93 $5d 'bracketright'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	__X_____,
	__X_____,
	__X_____,
	XXX_____,
	________,
//  94 $5e 'asciicircum'
//	width 4, bbx 0, bby 3, bbw 3, bbh 2
	_X______,
	X_X_____,
	________,
	________,
	________,
	________,
//  95 $5f 'underscore'
//	width 4, bbx 0, bby 0, bbw 3, bbh 1
	________,
	________,
	________,
	________,
	XXX_____,
	________,
//  96 $60 'grave'
//	width 4, bbx 0, bby 3, bbw 2, bbh 2
	X_______,
	_X______,
	________,
	________,
	________,
	________,
//  97 $61 'a'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	XX______,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
//  98 $62 'b'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	________,
//  99 $63 'c'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	X_______,
	X_______,
	_XX_____,
	________,
// 100 $64 'd'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_XX_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 101 $65 'e'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	X_X_____,
	XX______,
	_XX_____,
	________,
// 102 $66 'f'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_X______,
	XXX_____,
	_X______,
	_X______,
	________,
// 103 $67 'g'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	_XX_____,
	X_X_____,
	XXX_____,
	__X_____,
	_X______,
// 104 $68 'h'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
// 105 $69 'i'
//	width 4, bbx 1, bby 0, bbw 1, bbh 5
	_X______,
	________,
	_X______,
	_X______,
	_X______,
	________,
// 106 $6a 'j'
//	width 4, bbx 0, bby -1, bbw 3, bbh 6
	__X_____,
	________,
	__X_____,
	__X_____,
	X_X_____,
	_X______,
// 107 $6b 'k'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	X_X_____,
	XX______,
	XX______,
	X_X_____,
	________,
// 108 $6c 'l'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_X______,
	_X______,
	_X______,
	XXX_____,
	________,
// 109 $6d 'm'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	XXX_____,
	XXX_____,
	XXX_____,
	X_X_____,
	________,
// 110 $6e 'n'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	XX______,
	X_X_____,
	X_X_____,
	X_X_____,
	________,
// 111 $6f 'o'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_X______,
	X_X_____,
	X_X_____,
	_X______,
	________,
// 112 $70 'p'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	XX______,
	X_X_____,
	X_X_____,
	XX______,
	X_______,
// 113 $71 'q'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	_XX_____,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
// 114 $72 'r'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	X_______,
	X_______,
	X_______,
	________,
// 115 $73 's'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	XX______,
	_XX_____,
	XX______,
	________,
// 116 $74 't'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	XXX_____,
	_X______,
	_X______,
	_XX_____,
	________,
// 117 $75 'u'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	X_X_____,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 118 $76 'v'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	X_X_____,
	X_X_____,
	XXX_____,
	_X______,
	________,
// 119 $77 'w'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	X_X_____,
	XXX_____,
	XXX_____,
	XXX_____,
	________,
// 120 $78 'x'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	X_X_____,
	_X______,
	_X______,
	X_X_____,
	________,
// 121 $79 'y'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	X_X_____,
	X_X_____,
	_XX_____,
	__X_____,
	_X______,
// 122 $7a 'z'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	XXX_____,
	_XX_____,
	XX______,
	XXX_____,
	________,
// 123 $7b 'braceleft'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	_X______,
	X_______,
	_X______,
	_XX_____,
	________,
// 124 $7c 'bar'
//	width 4, bbx 1, bby 0, bbw 1, bbh 5
	_X______,
	_X______,
	________,
	_X______,
	_X______,
	________,
// 125 $7d 'braceright'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_X______,
	__X_____,
	_X______,
	XX______,
	________,
// 126 $7e 'asciitilde'
//	width 4, bbx 0, bby 3, bbw 3, bbh 2
	_XX_____,
	XX______,
	________,
	________,
	________,
	________,
// 161 $a1 'exclamdown'
//	width 4, bbx 1, bby 0, bbw 1, bbh 5
	_X______,
	________,
	_X______,
	_X______,
	_X______,
	________,
// 162 $a2 'cent'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	XXX_____,
	X_______,
	XXX_____,
	_X______,
	________,
// 163 $a3 'sterling'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	_X______,
	XXX_____,
	_X______,
	XXX_____,
	________,
// 164 $a4 'currency'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	_X______,
	XXX_____,
	_X______,
	X_X_____,
	________,
// 165 $a5 'yen'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	_X______,
	XXX_____,
	_X______,
	________,
// 166 $a6 'brokenbar'
//	width 4, bbx 1, bby 0, bbw 1, bbh 5
	_X______,
	_X______,
	________,
	_X______,
	_X______,
	________,
// 167 $a7 'section'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	_X______,
	X_X_____,
	_X______,
	XX______,
	________,
// 168 $a8 'dieresis'
//	width 4, bbx 0, bby 4, bbw 3, bbh 1
	X_X_____,
	________,
	________,
	________,
	________,
	________,
// 169 $a9 'copyright'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	_XX_____,
	X_______,
	_XX_____,
	________,
	________,
	________,
// 170 $aa 'ordfeminine'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_X_____,
	XXX_____,
	________,
	XXX_____,
	________,
// 171 $ab 'guillemotleft'
//	width 4, bbx 0, bby 2, bbw 2, bbh 3
	_X______,
	X_______,
	_X______,
	________,
	________,
	________,
// 172 $ac 'logicalnot'
//	width 4, bbx 0, bby 2, bbw 3, bbh 2
	________,
	XXX_____,
	__X_____,
	________,
	________,
	________,
// 173 $ad 'softhyphen'
//	width 4, bbx 0, bby 2, bbw 2, bbh 1
	________,
	________,
	XX______,
	________,
	________,
	________,
// 174 $ae 'registered'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	XX______,
	XX______,
	X_X_____,
	________,
	________,
	________,
// 175 $af 'macron'
//	width 4, bbx 0, bby 4, bbw 3, bbh 1
	XXX_____,
	________,
	________,
	________,
	________,
	________,
// 176 $b0 'degree'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	_X______,
	X_X_____,
	_X______,
	________,
	________,
	________,
// 177 $b1 'plusminus'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	XXX_____,
	_X______,
	________,
	XXX_____,
	________,
// 178 $b2 'twosuperior'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	XX______,
	_X______,
	_XX_____,
	________,
	________,
	________,
// 179 $b3 'threesuperior'
//	width 4, bbx 0, bby 2, bbw 3, bbh 3
	XXX_____,
	_XX_____,
	XXX_____,
	________,
	________,
	________,
// 180 $b4 'acute'
//	width 4, bbx 1, bby 3, bbw 2, bbh 2
	__X_____,
	_X______,
	________,
	________,
	________,
	________,
// 181 $b5 'mu'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	X_X_____,
	X_X_____,
	XX______,
	X_______,
	________,
// 182 $b6 'paragraph'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_X_____,
	_XX_____,
	_XX_____,
	_XX_____,
	________,
// 183 $b7 'periodcentered'
//	width 4, bbx 0, bby 1, bbw 3, bbh 3
	________,
	XXX_____,
	XXX_____,
	XXX_____,
	________,
	________,
// 184 $b8 'cedilla'
//	width 4, bbx 0, bby 0, bbw 3, bbh 3
	________,
	________,
	_X______,
	__X_____,
	XX______,
	________,
// 185 $b9 'onesuperior'
//	width 4, bbx 1, bby 2, bbw 1, bbh 3
	_X______,
	_X______,
	_X______,
	________,
	________,
	________,
// 186 $ba 'ordmasculine'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_X_____,
	_X______,
	________,
	XXX_____,
	________,
// 187 $bb 'guillemotright'
//	width 4, bbx 1, bby 2, bbw 2, bbh 3
	_X______,
	__X_____,
	_X______,
	________,
	________,
	________,
// 188 $bc 'onequarter'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	X_______,
	________,
	_XX_____,
	__X_____,
	________,
// 189 $bd 'onehalf'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	X_______,
	________,
	XX______,
	_XX_____,
	________,
// 190 $be 'threequarters'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	XX______,
	________,
	_XX_____,
	__X_____,
	________,
// 191 $bf 'questiondown'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	________,
	_X______,
	X_______,
	XXX_____,
	________,
// 192 $c0 'Agrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	_X______,
	XXX_____,
	X_X_____,
	________,
// 193 $c1 'Aacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	_X______,
	XXX_____,
	X_X_____,
	________,
// 194 $c2 'Acircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	_X______,
	XXX_____,
	X_X_____,
	________,
// 195 $c3 'Atilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	_X______,
	XXX_____,
	X_X_____,
	________,
// 196 $c4 'Adieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	_X______,
	X_X_____,
	XXX_____,
	X_X_____,
	________,
// 197 $c5 'Aring'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	XX______,
	X_X_____,
	XXX_____,
	X_X_____,
	________,
// 198 $c6 'AE'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 199 $c7 'Ccedilla'
//	width 4, bbx 0, bby -1, bbw 3, bbh 6
	_XX_____,
	X_______,
	X_______,
	_XX_____,
	__X_____,
	_X______,
// 200 $c8 'Egrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 201 $c9 'Eacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 202 $ca 'Ecircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 203 $cb 'Edieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 204 $cc 'Igrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	XXX_____,
	_X______,
	XXX_____,
	________,
// 205 $cd 'Iacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	XXX_____,
	_X______,
	XXX_____,
	________,
// 206 $ce 'Icircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	XXX_____,
	_X______,
	XXX_____,
	________,
// 207 $cf 'Idieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	XXX_____,
	_X______,
	XXX_____,
	________,
// 208 $d0 'Eth'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	X_X_____,
	XXX_____,
	X_X_____,
	XX______,
	________,
// 209 $d1 'Ntilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_XX_____,
	X_X_____,
	XXX_____,
	X_X_____,
	________,
// 210 $d2 'Ograve'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
// 211 $d3 'Oacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
// 212 $d4 'Ocircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
// 213 $d5 'Otilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_XX_____,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
// 214 $d6 'Odieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	XXX_____,
	X_X_____,
	XXX_____,
	________,
// 215 $d7 'multiply'
//	width 4, bbx 0, bby 1, bbw 3, bbh 3
	________,
	X_X_____,
	_X______,
	X_X_____,
	________,
	________,
// 216 $d8 'Oslash'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	X_X_____,
	XXX_____,
	X_X_____,
	XX______,
	________,
// 217 $d9 'Ugrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
// 218 $da 'Uacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_X______,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
// 219 $db 'Ucircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
// 220 $dc 'Udieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	XXX_____,
	________,
// 221 $dd 'Yacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_X______,
	X_X_____,
	XXX_____,
	_X______,
	________,
// 222 $de 'Thorn'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	XXX_____,
	X_X_____,
	XXX_____,
	X_______,
	________,
// 223 $df 'germandbls'
//	width 4, bbx 0, bby -1, bbw 3, bbh 6
	_XX_____,
	X_X_____,
	XX______,
	X_X_____,
	XX______,
	X_______,
// 224 $e0 'agrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 225 $e1 'aacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 226 $e2 'acircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 227 $e3 'atilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 228 $e4 'adieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 229 $e5 'aring'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	_XX_____,
	_XX_____,
	X_X_____,
	XXX_____,
	________,
// 230 $e6 'ae'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	XXX_____,
	XXX_____,
	XX______,
	________,
// 231 $e7 'ccedilla'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	_XX_____,
	X_______,
	_XX_____,
	__X_____,
	_X______,
// 232 $e8 'egrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	_XX_____,
	XXX_____,
	_XX_____,
	________,
// 233 $e9 'eacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	_XX_____,
	XXX_____,
	_XX_____,
	________,
// 234 $ea 'ecircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	_XX_____,
	XXX_____,
	_XX_____,
	________,
// 235 $eb 'edieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	_XX_____,
	XXX_____,
	_XX_____,
	________,
// 236 $ec 'igrave'
//	width 4, bbx 1, bby 0, bbw 2, bbh 5
	_X______,
	__X_____,
	_X______,
	_X______,
	_X______,
	________,
// 237 $ed 'iacute'
//	width 4, bbx 0, bby 0, bbw 2, bbh 5
	_X______,
	X_______,
	_X______,
	_X______,
	_X______,
	________,
// 238 $ee 'icircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	_X______,
	_X______,
	_X______,
	________,
// 239 $ef 'idieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	_X______,
	_X______,
	_X______,
	________,
// 240 $f0 'eth'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	_XX_____,
	X_X_____,
	_XX_____,
	________,
// 241 $f1 'ntilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_XX_____,
	XX______,
	X_X_____,
	X_X_____,
	________,
// 242 $f2 'ograve'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	__X_____,
	_X______,
	X_X_____,
	_X______,
	________,
// 243 $f3 'oacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	X_______,
	_X______,
	X_X_____,
	_X______,
	________,
// 244 $f4 'ocircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	_X______,
	X_X_____,
	_X______,
	________,
// 245 $f5 'otilde'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XX______,
	_XX_____,
	_X______,
	X_X_____,
	_X______,
	________,
// 246 $f6 'odieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	_X______,
	X_X_____,
	_X______,
	________,
// 247 $f7 'divide'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_X______,
	________,
	XXX_____,
	________,
	_X______,
	________,
// 248 $f8 'oslash'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	XXX_____,
	X_X_____,
	XX______,
	________,
// 249 $f9 'ugrave'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_______,
	_X______,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 250 $fa 'uacute'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	__X_____,
	_X______,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 251 $fb 'ucircumflex'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	XXX_____,
	________,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 252 $fc 'udieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	X_X_____,
	X_X_____,
	_XX_____,
	________,
// 253 $fd 'yacute'
//	width 4, bbx 0, bby -1, bbw 3, bbh 6
	__X_____,
	_X______,
	X_X_____,
	_XX_____,
	__X_____,
	_X______,
// 254 $fe 'thorn'
//	width 4, bbx 0, bby -1, bbw 3, bbh 5
	________,
	X_______,
	XX______,
	X_X_____,
	XX______,
	X_______,
// 255 $ff 'ydieresis'
//	width 4, bbx 0, bby -1, bbw 3, bbh 6
	X_X_____,
	________,
	X_X_____,
	_XX_____,
	__X_____,
	_X______,
// 285 $11d 'gcircumflex'
//	width 6, bbx 0, bby 0, bbw 1, bbh 1
	________,
	________,
	________,
	________,
	________,
	________,
// 338 $152 'OE'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XX______,
	XXX_____,
	XX______,
	_XX_____,
	________,
// 339 $153 'oe'
//	width 4, bbx 0, bby 0, bbw 3, bbh 4
	________,
	_XX_____,
	XXX_____,
	XX______,
	XXX_____,
	________,
// 352 $160 'Scaron'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	_XX_____,
	XX______,
	_XX_____,
	XX______,
	________,
// 353 $161 'scaron'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	_XX_____,
	XX______,
	_XX_____,
	XX______,
	________,
// 376 $178 'Ydieresis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	________,
	X_X_____,
	_X______,
	_X______,
	________,
// 381 $17d 'Zcaron'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	_XX_____,
	XX______,
	XXX_____,
	________,
// 382 $17e 'zcaron'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	X_X_____,
	XXX_____,
	_XX_____,
	XX______,
	XXX_____,
	________,
// 3748 $ea4 'uni0EA4'
//	width 6, bbx 0, bby 0, bbw 1, bbh 1
	________,
	________,
	________,
	________,
	________,
	________,
// 5024 $13a0 'uni13A0'
//	width 6, bbx 0, bby 0, bbw 1, bbh 1
	________,
	________,
	________,
	________,
	________,
	________,
// 8226 $2022 'bullet'
//	width 4, bbx 1, bby 2, bbw 1, bbh 1
	________,
	________,
	_X______,
	________,
	________,
	________,
// 8230 $2026 'ellipsis'
//	width 4, bbx 0, bby 0, bbw 3, bbh 1
	________,
	________,
	________,
	________,
	X_X_____,
	________,
// 8364 $20ac 'Euro'
//	width 4, bbx 0, bby 0, bbw 3, bbh 5
	_XX_____,
	XXX_____,
	XXX_____,
	XX______,
	_XX_____,
	________,
};

const byte *bFont = font_data;
