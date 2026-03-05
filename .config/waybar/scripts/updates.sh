#!/bin/bash

UPDATES=$(checkupdates | wc -l)
AUR=$(yay -Qua | wc -l) # Jeśli używasz paru, zmień na paru -Qua

TOTAL=$((UPDATES + AUR))

if [ "$TOTAL" -gt 0 ]; then
    echo "{\"text\": \"$TOTAL\", \"tooltip\": \"Pacman: $UPDATES\nAUR: $AUR\", \"class\": \"pending\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"System aktualny\", \"class\": \"updated\"}"
fi
