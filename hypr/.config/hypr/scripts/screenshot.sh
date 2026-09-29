#!/usr/bin/env bash
# grim + slurp screenshot, bound to Print and SUPER+SHIFT+P.
# "region"/"screen" save a file and copy it; "copy ..." only copy.
set -euo pipefail

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/screenshots"

mode=$(printf 'copy region\ncopy screen\nregion\nscreen\n' \
    | fuzzel --dmenu --prompt 'screenshot: ' --lines 4) || exit 0

case "$mode" in
    "copy region")
        geometry=$(slurp) || exit 0
        grim -g "$geometry" - | wl-copy --type image/png
        notify-send "screenshot" "copied to clipboard"
        exit 0
        ;;
    "copy screen")
        grim - | wl-copy --type image/png
        notify-send "screenshot" "copied to clipboard"
        exit 0
        ;;
esac

mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

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

wl-copy --type image/png < "$file"
notify-send "screenshot" "saved to $file"
