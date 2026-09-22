#!/usr/bin/env bash
# fuzzel-backed power menu, bound to SUPER+Backspace.
set -euo pipefail

choice=$(printf 'lock\nlogout\nsuspend\nreboot\nshutdown\n' \
    | fuzzel --dmenu --prompt 'power: ' --lines 5) || exit 0

case "$choice" in
    lock)     loginctl lock-session ;;
    logout)   hyprctl dispatch exit ;;
    suspend)  systemctl suspend ;;
    reboot)   systemctl reboot ;;
    shutdown) systemctl poweroff ;;
esac
