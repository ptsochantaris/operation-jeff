CONV=../../Gfx2Next/build/gfx2next
SRC=~/Desktop/
LETTERS=(A B C D E F G H I J)

for LETTER in "${LETTERS[@]}"; do
    "${CONV}" "${SRC}OperationJeffLevel${LETTER}.png" -pal-min -bitmap-y -bank-16k "level${LETTER}.nxi"
done
