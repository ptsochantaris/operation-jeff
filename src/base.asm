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

PUBLIC _audio_zzzap
PUBLIC _audio_zzzap_len
_audio_zzzap:
    BINARY "resources/zzzap.pcm"
_audio_zzzap_len:
    defw $-_audio_zzzap

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

SECTION PAGE_148
    BINARY "resources/menu.pcm"

SECTION PAGE_150
ORG 0

PUBLIC _title_palette
_title_palette:
    BINARY "resources/title.nxp"

PUBLIC _info_palette
_info_palette:
    BINARY "resources/info.nxp"

PUBLIC _default_palette
_default_palette:
    BINARY "resources/default.pal"

PUBLIC _level_a_palette
_level_a_palette:
    BINARY "resources/levelA.nxp"

PUBLIC _level_b_palette
_level_b_palette:
    BINARY "resources/levelB.nxp"

PUBLIC _level_c_palette
_level_c_palette:
    BINARY "resources/levelC.nxp"

PUBLIC _level_d_palette
_level_d_palette:
    BINARY "resources/levelD.nxp"

PUBLIC _level_e_palette
_level_e_palette:
    BINARY "resources/levelE.nxp"

PUBLIC _level_f_palette
_level_f_palette:
    BINARY "resources/levelF.nxp"

PUBLIC _level_g_palette
_level_g_palette:
    BINARY "resources/levelG.nxp"

PUBLIC _level_h_palette
_level_h_palette:
    BINARY "resources/levelH.nxp"


SECTION PAGE_151 ; also 152
    BINARY "resources/sprites.spr"
