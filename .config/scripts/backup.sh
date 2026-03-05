#!/bin/bash

BACKUP_DIR="$HOME/bobby-dotfiles"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

FOLDERS=("hypr" "waybar" "quickshell" "kitty" "dunst" "rofi" "scripts" "fastfetch" "swaync")

echo -e "\033[1;34m[*] Creating copy...\033[0m"

mkdir -p "$BACKUP_DIR/.config"

for folder in "${FOLDERS[@]}"; do
    if [ -d "$HOME/.config/$folder" ]; then
        echo -e "\033[0;32m[+] Copium: $folder\033[0m"
        rm -rf "$BACKUP_DIR/.config/$folder" 
        cp -r "$HOME/.config/$folder" "$BACKUP_DIR/.config/"
    fi
done

if [ -d "$HOME/GrindStone" ]; then
    echo -e "\033[0;32m[+] Copy: GrindStone\033[0m"
    rm -rf "$BACKUP_DIR/GrindStone"
    cp -r "$HOME/GrindStone" "$BACKUP_DIR/"
fi

cd "$BACKUP_DIR" || exit

if [ -d ".git" ]; then
    echo -e "\033[1;34m[*] Transfering to GitHub...\033[0m"
    git add .
    git commit -m "Backup: $TIMESTAMP"
    git push origin main
    echo -e "\033[1;32m[!] Backup done.\033[0m"
else
    echo -e "\033[1;33m[!] Failed, save: $BACKUP_DIR.\033[0m"
fi
