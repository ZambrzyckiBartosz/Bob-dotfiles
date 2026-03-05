#!/bin/bash

WALL_DIR="$HOME/wallpapers"
BLURRED="$HOME/wallpapers/.current-blurred.jpg"
CURRENT_WALL="$HOME/wallpapers/current"

selected_path=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.png' -o -iname '*.webp' \) ! -name ".*" | shuf -n1)

if [ -f "$selected_path" ]; then
  ln -sf "$selected_path" "$CURRENT_WALL"

  swww img "$selected_path" --transition-type any --transition-duration 2 &
  wal -i "$selected_path" -n -q

  cp ~/.cache/wal/colors-swaync.css ~/.config/swaync/style.css
  pkill -SIGUSR1 swaync
  
  killall waybar && waybar & disown
  killall quickshell
  sleep 0.2
  nohup quickshell >/dev/null 2>&1 &
  
  (
    rm -rf ~/.themes/Dynamic
    rm -rf ~/.local/share/themes/Dynamic

    oomox-cli ~/.cache/wal/colors-oomox -o Dynamic >/dev/null 2>&1
    
    mkdir -p ~/.local/share/themes
    
    if [ -d "$HOME/.themes/Dynamic" ]; then
        cp -r ~/.themes/Dynamic ~/.local/share/themes/
    fi

    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface gtk-theme 'Dynamic'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  ) &

  if [[ "$selected_path" == *.gif ]]; then
    magick "${selected_path}[0]" -resize 1920x -blur 0x8 -quality 85 "$BLURRED" &
  else
    magick "$selected_path" -resize 1920x -blur 0x8 -quality 85 "$BLURRED" &
  fi
  
  wait
fi
