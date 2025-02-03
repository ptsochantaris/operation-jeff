SECTION PAGE_28
ORG 0

    DEFB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DEFB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DEFB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DEFB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DEFB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DEFB 0, 0, 0, 0, 0, 0

_isr:
    ei
    ret

SECTION PAGE_29
    BINARY "resources/title_0.nxi" ; 29
    BINARY "resources/title_1.nxi" ; 31
    BINARY "resources/title_2.nxi" ; 33
    BINARY "resources/title_3.nxi" ; 35
SECTION PAGE_37
    BINARY "resources/title_4.nxi" ; 37
    BINARY "resources/info_0.nxi" ; 39
    BINARY "resources/info_1.nxi" ; 41
    BINARY "resources/info_2.nxi" ; 43
SECTION PAGE_45
    BINARY "resources/info_3.nxi" ; 45
    BINARY "resources/info_4.nxi" ; 47
    BINARY "resources/levelA_0.nxi" ; 49
    BINARY "resources/levelA_1.nxi" ; 51
SECTION PAGE_53
    BINARY "resources/levelA_2.nxi" ; 53
    BINARY "resources/levelA_3.nxi" ; 55
    BINARY "resources/levelA_4.nxi" ; 57
    BINARY "resources/levelB_0.nxi" ; 59
SECTION PAGE_61
    BINARY "resources/levelB_1.nxi" ; 61
    BINARY "resources/levelB_2.nxi" ; 62
    BINARY "resources/levelB_3.nxi" ; 65
    BINARY "resources/levelB_4.nxi" ; 67
SECTION PAGE_69
    BINARY "resources/levelC_0.nxi" ; 69
    BINARY "resources/levelC_1.nxi" ; 71
    BINARY "resources/levelC_2.nxi" ; 73
    BINARY "resources/levelC_3.nxi" ; 75
SECTION PAGE_77
    BINARY "resources/levelC_4.nxi" ; 77
    BINARY "resources/levelD_0.nxi" ; 79
    BINARY "resources/levelD_1.nxi" ; 81
    BINARY "resources/levelD_2.nxi" ; 83
SECTION PAGE_85
    BINARY "resources/levelD_3.nxi" ; 85
    BINARY "resources/levelD_4.nxi" ; 87
    BINARY "resources/levelE_0.nxi" ; 89
    BINARY "resources/levelE_1.nxi" ; 91
SECTION PAGE_93
    BINARY "resources/levelE_2.nxi" ; 93
    BINARY "resources/levelE_3.nxi" ; 95
    BINARY "resources/levelE_4.nxi" ; 97
    BINARY "resources/levelF_0.nxi" ; 99
SECTION PAGE_101
    BINARY "resources/levelF_1.nxi" ; 101
    BINARY "resources/levelF_2.nxi" ; 103
    BINARY "resources/levelF_3.nxi" ; 105
    BINARY "resources/levelF_4.nxi" ; 107
SECTION PAGE_109
    BINARY "resources/levelG_0.nxi" ; 109
    BINARY "resources/levelG_1.nxi" ; 111
    BINARY "resources/levelG_2.nxi" ; 113
    BINARY "resources/levelG_3.nxi" ; 115
SECTION PAGE_117
    BINARY "resources/levelG_4.nxi" ; 117
    BINARY "resources/levelH_0.nxi" ; 119
    BINARY "resources/levelH_1.nxi" ; 121
    BINARY "resources/levelH_2.nxi" ; 123
SECTION PAGE_125
    BINARY "resources/levelH_3.nxi" ; 125
    BINARY "resources/levelH_4.nxi" ; 127
    BINARY "resources/levelI_0.nxi" ; 129
    BINARY "resources/levelI_1.nxi" ; 131
SECTION PAGE_133
    BINARY "resources/levelI_2.nxi" ; 133
    BINARY "resources/levelI_3.nxi" ; 135
    BINARY "resources/levelI_4.nxi" ; 137
    BINARY "resources/levelJ_0.nxi" ; 139
SECTION PAGE_141
    BINARY "resources/levelJ_1.nxi" ; 141
    BINARY "resources/levelJ_2.nxi" ; 143
    BINARY "resources/levelJ_3.nxi" ; 145
    BINARY "resources/levelJ_4.nxi" ; 147
SECTION PAGE_149
    BINARY "resources/levelK_0.nxi" ; 149
    BINARY "resources/levelK_1.nxi" ; 151
    BINARY "resources/levelK_2.nxi" ; 153
    BINARY "resources/levelK_3.nxi" ; 155
SECTION PAGE_157
    BINARY "resources/levelK_4.nxi" ; 157
    BINARY "resources/levelL_0.nxi" ; 159
    BINARY "resources/levelL_1.nxi" ; 161
    BINARY "resources/levelL_2.nxi" ; 163
SECTION PAGE_165
    BINARY "resources/levelL_3.nxi" ; 165
    BINARY "resources/levelL_4.nxi" ; 167
    BINARY "resources/gameOverScreen_0.nxi" ; 169
    BINARY "resources/gameOverScreen_1.nxi" ; 171
SECTION PAGE_173
    BINARY "resources/gameOverScreen_2.nxi" ; 173
    BINARY "resources/gameOverScreen_3.nxi" ; 175
    BINARY "resources/gameOverScreen_4.nxi" ; 177

SECTION PAGE_191 ; also 192
    BINARY "resources/sprites.spr"

SECTION PAGE_205
    BINARY "resources/zzzap.pcm"

SECTION PAGE_206
    BINARY "resources/siren.pcm"

SECTION PAGE_208
    BINARY "resources/menu.pcm"

SECTION PAGE_210
ORG 0x6000

PUBLIC _title_palette
_title_palette:
    BINARY "resources/title.nxp"

PUBLIC _info_palette
_info_palette:
    BINARY "resources/info.nxp"

PUBLIC _default_palette
_default_palette:
    BINARY "resources/default.pal"

PUBLIC _level_palettes
_level_palettes:
    BINARY "resources/levelA.nxp"
    BINARY "resources/levelB.nxp"
    BINARY "resources/levelC.nxp"
    BINARY "resources/levelD.nxp"
    BINARY "resources/levelE.nxp"
    BINARY "resources/levelF.nxp"
    BINARY "resources/levelG.nxp"
    BINARY "resources/levelH.nxp"
    BINARY "resources/levelI.nxp"
    BINARY "resources/levelJ.nxp"
    BINARY "resources/levelK.nxp"
    BINARY "resources/levelL.nxp"

PUBLIC _gameOverPalette
_gameOverPalette:
    BINARY "resources/gameOverScreen.nxp"
