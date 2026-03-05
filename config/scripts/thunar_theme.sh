#!/bin/bash

wal -c
wal -i /home/bob/wallpapers/current
oomox-cli /home/bob/.cache/wal/colors-oomox -o Dym
GTK_THEME=Dym thunar

