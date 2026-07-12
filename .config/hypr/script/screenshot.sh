#!/bin/sh
# Screenshot helper for Hyprland
# Usage: screenshot.sh [full|region|window]

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

case "${1:-full}" in
    full)
        grim - | satty --filename -
				;;
    region)
        grim -g "$(slurp)" - | satty --filename -
				;;
    window)
        W=$(hyprctl activewindow -j)
        GEOM=$(echo "$W" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$GEOM" - | satty --filename -
				;;
    *)
        echo "Usage: $0 [full|region|window]"
        exit 1
        ;;
esac
