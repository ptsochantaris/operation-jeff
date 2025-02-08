CONV=../Gfx2Next/build/gfx2next
COMPRESS=../ZX0/src/zx0
ORIG=resources_original/
DST=resources/
LETTERS=(A B C D E F G H I J K L M N)
NUMBERS=(0 1 2 3 4 5 6 7 8 9)

rm $DST*

cp ${ORIG}*.pcm ${ORIG}*.nxp ${ORIG}*.spr resources

$CONV "${ORIG}OperationJeffTitle.png" -pal-min -bitmap-y -bank-8k "${DST}title.nxi" &
$CONV "${ORIG}OperationJeffInfo.png" -pal-min -bitmap-y -bank-8k "${DST}info.nxi" &
$CONV "${ORIG}OperationJeffGameOver.png" -pal-min -bitmap-y -bank-8k "${DST}gameOverScreen.nxi" &

for LETTER in "${LETTERS[@]}"; do
    $CONV "${ORIG}OperationJeffLevel${LETTER}.png" -pal-min -bitmap-y -bank-8k "${DST}level${LETTER}.nxi" &
done

wait

for LETTER in "${LETTERS[@]}"; do
    $COMPRESS -f "${DST}level${LETTER}.nxp" "${DST}level${LETTER}.nxp.zx0" &

    for NUMBER in "${NUMBERS[@]}"; do
        $COMPRESS -f "${DST}level${LETTER}_${NUMBER}.nxi" "${DST}level${LETTER}_${NUMBER}.nxi.zx0" &
    done
done

SCREENS=(title info gameOverScreen)
for SCREEN in "${SCREENS[@]}"; do
    for NUMBER in "${NUMBERS[@]}"; do
        $COMPRESS -f "${DST}/${SCREEN}_${NUMBER}.nxi" "${DST}/${SCREEN}_${NUMBER}.nxi.zx0" &
    done
done

PALETTES=(title info gameOverScreen default)
for PALETTE in "${PALETTES[@]}"; do
    $COMPRESS -f "${DST}/${PALETTE}.nxp" "${DST}/${PALETTE}.nxp.zx0" &
done

wait

rm $DST*.nxp $DST*.nxi

$CONV "${ORIG}OperationJeffLoading.png" -pal-min -pal-embed -bitmap "${DST}loadingScreen.nxi" &

swift makeResources.swift resources/*.nxp.zx0 resources/*.pcm resources/*.nxi.zx0 resources/*.spr
