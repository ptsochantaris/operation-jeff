CONV=../../Gfx2Next/build/gfx2next
SRC=~/Desktop/
LETTERS=(A B C D E F G H I J K L)

for LETTER in "${LETTERS[@]}"; do
    "${CONV}" "${SRC}OperationJeffLevel${LETTER}.png" -pal-min -bitmap-y -bank-16k "level${LETTER}.nxi"
done

"${CONV}" "${SRC}OperationJeffLoading.png" -pal-min -pal-embed -bitmap "loadingScreen.nxi"
"${CONV}" "${SRC}OperationJeffGameOver.png" -pal-min -bitmap-y -bank-16k "gameOverScreen.nxi"
