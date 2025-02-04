CONV=../../Gfx2Next/build/gfx2next
SRC=../resources_original/OperationJeff
LETTERS=(A B C D E F G H I J K L)

for LETTER in "${LETTERS[@]}"; do
    "${CONV}" "${SRC}Level${LETTER}.png" -pal-min -bitmap-y -bank-16k "level${LETTER}.nxi"
done

"${CONV}" "${SRC}Loading.png" -pal-min -pal-embed -bitmap "loadingScreen.nxi"
"${CONV}" "${SRC}Title.png" -pal-min -bitmap-y -bank-16k "title.nxi"
"${CONV}" "${SRC}Info.png" -pal-min -bitmap-y -bank-16k "info.nxi"
"${CONV}" "${SRC}GameOver.png" -pal-min -bitmap-y -bank-16k "gameOverScreen.nxi"
