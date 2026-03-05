#!/bin/bash

GIF_DIR="/home/bob/bobby-dotfiles/Gif" 

TEKST="${1:-}"

GIF_FILES=("$GIF_DIR"/*.gif)

if [[ ! -e "${GIF_FILES[0]}" ]]; then
    exit 1
fi

RANDOM_INDEX=$((RANDOM % ${#GIF_FILES[@]}))
GIF_PATH="${GIF_FILES[$RANDOM_INDEX]}"

TERM_COLS=$(tput cols)
TERM_LINES=$(tput lines)

IMG_HEIGHT=$((TERM_LINES - 4))
IMG_WIDTH=$((TERM_COLS / 2)) 

TEXT_COL=$((IMG_WIDTH + 5))
TEXT_ROW=$((TERM_LINES / 3))

tput smcup
tput civis
clear

trap 'tput cnorm; tput rmcup; clear; exit' SIGINT EXIT

echo -ne "\033[${TEXT_ROW};${TEXT_COL}H${TEKST}"

echo -ne "\033[1;1H"
chafa -f symbols -c none --symbols braille --size ${IMG_WIDTH}x${IMG_HEIGHT} "$GIF_PATH"
