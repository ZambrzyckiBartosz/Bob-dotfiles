#!/bin/bash

if pidof gpu-screen-recorder > /dev/null; then
    echo '{"text": "󰑊 REC", "class": "recording", "tooltip": "Recording"}'
else
    echo '{"text": "", "class": "stopped", "tooltip": ""}'
fi
