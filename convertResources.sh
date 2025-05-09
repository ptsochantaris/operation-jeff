CONV=../Gfx2Next/build/gfx2next
COMPRESS=../ZX0/src/zx0
ORIG=resources_original/
DST=resources/
LETTERS=(A B C D E F G H I J K L M N O P)
NUMBERS=(0 1 2 3 4 5 6 7 8 9)

bordered_output() {
#  local input="$1"
#  local border_length=$(( ${#input} + 4 ))
#  printf "\n\n%s\n" $(printf "#%.0s" $(seq 1 $border_length))
#  printf "# %s #\n" "$input"
#  printf "%s\n\n" $(printf "#%.0s" $(seq 1 $border_length))
    echo ">> $1"
}

rm $DST*

cp ${ORIG}*.pcm ${ORIG}*.nxp ${ORIG}*.spr resources

bordered_output "Title Screen"
$CONV "${ORIG}OperationJeffTitle.png" -pal-min -bitmap-y -bank-8k "${DST}title.nxi" > /dev/null 
bordered_output "Info Screen"
$CONV "${ORIG}OperationJeffInfo.png" -pal-min -bitmap-y -bank-8k "${DST}info.nxi" > /dev/null 
bordered_output "Game Over Screens"
$CONV "${ORIG}OperationJeffGameOver.png" -pal-min -bitmap-y -bank-8k "${DST}gameOverScreen.nxi" > /dev/null 

SCREENS=(title info gameOverScreen)
for SCREEN in "${SCREENS[@]}"; do
    bordered_output "Compression: ${SCREEN}"
    for NUMBER in "${NUMBERS[@]}"; do
        $COMPRESS -f "${DST}/${SCREEN}_${NUMBER}.nxi" "${DST}/${SCREEN}_${NUMBER}.nxi.zx0" > /dev/null &
    done
    wait
done

bordered_output "Compression: Palettes"
PALETTES=(title info gameOverScreen default)
for PALETTE in "${PALETTES[@]}"; do
    $COMPRESS -f "${DST}/${PALETTE}.nxp" "${DST}/${PALETTE}.nxp.zx0" > /dev/null &
done
wait

bordered_output "Converting heightmaps"
swift convertHeightmaps.swift ${ORIG}OperationJeffHeightmap*.png > /dev/null 

for LETTER in "${LETTERS[@]}"; do
    bordered_output "Level ${LETTER}"
    $CONV "${ORIG}OperationJeffLevel${LETTER}.png" -pal-min -bitmap-y -bank-8k "${DST}level${LETTER}.nxi" > /dev/null 

    $COMPRESS -f "${DST}level${LETTER}.nxp" "${DST}level${LETTER}.nxp.zx0" > /dev/null &
    $COMPRESS -f "${ORIG}OperationJeffHeightmap${LETTER}.hm" "${DST}heightmap${LETTER}.hm.zx0" > /dev/null &

    for NUMBER in "${NUMBERS[@]}"; do
        $COMPRESS -f "${DST}level${LETTER}_${NUMBER}.nxi" "${DST}level${LETTER}_${NUMBER}.nxi.zx0" > /dev/null &
    done
    wait
done

rm $DST*.nxp $DST*.nxi $ORIG*.hm

bordered_output "Creating assets.h and assets.asm"
swift makeAssets.swift resources/*.nxp.zx0 resources/*.pcm resources/*.nxi.zx0 resources/*.spr resources/*.hm.zx0 > /dev/null 

bordered_output "Loading screen"
$CONV "${ORIG}OperationJeffLoading.png" -pal-min -pal-embed -bitmap "${DST}loadingScreen.nxi" > /dev/null 

bordered_output "All done"
