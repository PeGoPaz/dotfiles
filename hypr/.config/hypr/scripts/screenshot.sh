#!/usr/bin/env bash
# grim + slurp screenshot, bound to Print. Copies to the clipboard as well.
set -euo pipefail

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

mode=$(printf 'region\nscreen\n' \
    | fuzzel --dmenu --prompt 'screenshot: ' --lines 2) || exit 0

case "$mode" in
    region)
        geometry=$(slurp) || exit 0
        grim -g "$geometry" "$file"
        ;;
    screen)
        grim "$file"
        ;;
    *)
        exit 0
        ;;
esac

wl-copy < "$file"
notify-send "screenshot" "saved to $file"
