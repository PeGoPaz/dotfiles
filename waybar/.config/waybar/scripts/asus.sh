#!/usr/bin/env bash
# Waybar module for the ASUS layer: power profile + charge limit.
#   asus.sh          print status as JSON for waybar
#   asus.sh profile  cycle the power profile (left click)
#   asus.sh limit    toggle the charge limit 80 <-> 100 (right click)
# After a change waybar is poked with RTMIN+8 so the icon updates at once.
set -euo pipefail

bat=$(ls -d /sys/class/power_supply/BAT* | head -1)

case "${1:-status}" in
    profile)
        asusctl profile next >/dev/null
        pkill -RTMIN+8 waybar || true
        exit 0
        ;;
    limit)
        if [ "$(cat "$bat/charge_control_end_threshold")" -ge 100 ]; then
            asusctl battery limit 80 >/dev/null
        else
            asusctl battery limit 100 >/dev/null
        fi
        pkill -RTMIN+8 waybar || true
        exit 0
        ;;
esac

profile=$(asusctl profile get 2>/dev/null | awk '/^Active profile/{print $NF}')
limit=$(cat "$bat/charge_control_end_threshold")

case "$profile" in
    Quiet)       icon="󰾆" ;;
    Balanced)    icon="󰾅" ;;
    Performance) icon="󰓅" ;;
    *)           icon="?" ;;
esac

# Bolt next to the gauge only while charging to 100% - the unusual state.
text="$icon"
[ "$limit" -ge 100 ] && text="$icon 󱐋"

printf '{"text":"%s","tooltip":"profile: %s (click)\\ncharge limit: %s%% (right-click)"}\n' \
    "$text" "${profile:-unknown}" "$limit"
