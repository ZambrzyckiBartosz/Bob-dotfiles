#!/usr/bin/env bash

thumb_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
mkdir -p "$thumb_dir"
cliphist_list="$(cliphist list)"

for thumb in "$thumb_dir"/*; do
    clip_id="${thumb##*/}"
    clip_id="${clip_id%.*}"
    check=$(rg <<< "$cliphist_list" "^$clip_id\s")
    if [ -z "$check" ]; then
        >&2 rm -v "$thumb"
    fi
done

read -r -d '' prog <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
    image = grp[1]"."grp[3]
    system("[ -f $thumb_dir/"image" ] || echo " grp[1] "\\\\\\t | cliphist decode | magick - -resize '256x256>' $thumb_dir/"image )
    print "img:$thumb_dir/"image
    next
}
1
EOF

choice=$(gawk <<< $cliphist_list "$prog" | wofi -I --dmenu --style ~/.config/wofi/style.css --width 600 --height 500 --prompt "Clipboard" --cache-file=/dev/null -Dimage_size=80)

[ -z "$choice" ] && exit 1

if [ "${choice::4}" = "img:" ]; then
    thumb_file="${choice:4}"
    clip_id="${thumb_file##*/}"
    clip_id="${clip_id%.*}\t"
else
    clip_id="${choice}"
fi

printf "$clip_id" | cliphist decode
