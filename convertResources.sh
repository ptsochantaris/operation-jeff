CONV=../Gfx2Next/build/gfx2next
COMPRESS=../ZX0/src/zx0
SRC=resources_original/OperationJeff
DST=resources/
LETTERS=(A B C D E F G H I J K L)
NUMBERS=(0 1 2 3 4 5 6 7 8 9)

rm "${DST}*.nxi" "${DST}level*.nxp" "${DST}*.zx0"

for LETTER in "${LETTERS[@]}"; do
    "${CONV}" "${SRC}Level${LETTER}.png" -pal-min -bitmap-y -bank-8k "${DST}level${LETTER}.nxi"

    for NUMBER in "${NUMBERS[@]}"; do
        "${COMPRESS}" -f "${DST}level${LETTER}_${NUMBER}.nxi" "${DST}level${LETTER}_${NUMBER}.nxi.zx0"
        rm "${DST}level${LETTER}_${NUMBER}.nxi"
    done
done

"${CONV}" "${SRC}Title.png" -pal-min -bitmap-y -bank-8k "${DST}title.nxi"
"${CONV}" "${SRC}Info.png" -pal-min -bitmap-y -bank-8k "${DST}info.nxi"
"${CONV}" "${SRC}GameOver.png" -pal-min -bitmap-y -bank-8k "${DST}gameOverScreen.nxi"

SCREENS=(title info gameOverScreen)
for SCREEN in "${SCREENS[@]}"; do
    for NUMBER in "${NUMBERS[@]}"; do
        "${COMPRESS}" -f "${DST}/${SCREEN}_${NUMBER}.nxi" "${DST}/${SCREEN}_${NUMBER}.nxi.zx0"
        rm "${DST}/${SCREEN}_${NUMBER}.nxi"
    done
done

"${CONV}" "${SRC}Loading.png" -pal-min -pal-embed -bitmap "${DST}loadingScreen.nxi"

swift makeResources.swift resources/*.nxp resources/*.spr resources/*.pcm resources/*.nxi.zx0
