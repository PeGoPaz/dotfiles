#!/usr/bin/env bash
# Checks the things a first boot has to settle. Everything else in this repo was
# checked against upstream source before the laptop existed.
#
# Exits non-zero if any check FAILs. SKIP means "needs a human", not "broken".

fails=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fails=$((fails + 1)); }
skip() { printf '  \033[33mSKIP\033[0m  %s\n' "$1"; }
section() { printf '\n%s\n' "$1"; }

need() { command -v "$1" >/dev/null 2>&1; }

# --- Hyprland is actually running -------------------------------------------
section "session"
if ! need hyprctl || ! hyprctl version >/dev/null 2>&1; then
    fail "hyprctl does not answer - run this from inside a Hyprland session"
    exit 1
fi
pass "hyprland $(hyprctl version | awk '/^Hyprland/{print $2; exit}')"

# --- config errors -----------------------------------------------------------
# With no errors the reply is empty or a lone newline, so drop blank lines.
errs=$(hyprctl configerrors 2>/dev/null | grep -v '^[[:space:]]*$')
if [ -z "$errs" ]; then
    pass "no config errors"
else
    fail "config errors reported:"
    printf '%s\n' "$errs" | sed 's/^/        /'
fi

# --- monitor -----------------------------------------------------------------
section "monitor"
if need jq; then
    read -r w h rr sc <<<"$(hyprctl monitors -j | jq -r '.[] | select(.name=="eDP-1")
        | "\(.width) \(.height) \(.refreshRate) \(.scale)"')"
    if [ -z "$w" ]; then
        fail "eDP-1 not found in hyprctl monitors"
    else
        [ "$w" = "2560" ] && [ "$h" = "1600" ] \
            && pass "eDP-1 is ${w}x${h}" || fail "eDP-1 is ${w}x${h}, expected 2560x1600"
        printf '%s' "$rr" | grep -qE '^16[45]' \
            && pass "refresh ${rr}Hz" || fail "refresh ${rr}Hz, expected ~165"
        printf '%s' "$sc" | grep -qE '^1\.6' \
            && pass "scale $sc gives a whole 1600x1000" || fail "scale $sc, expected 1.60"
    fi
else
    skip "jq not installed - cannot read hyprctl monitors -j"
fi

# --- options really applied ---------------------------------------------------
section "options applied"
# getoption answers "<type>: <value>" on its first line, e.g. "bool: true",
# "int: 1", "str: us,ru". Anything without a colon ("no such option") is a miss.
opt() { # opt <name> <expected>
    local raw got=""
    raw=$(hyprctl getoption "$1" 2>/dev/null | head -1)
    case "$raw" in *": "*) got=${raw#*: } ;; esac
    if [ -z "$got" ]; then
        fail "$1 - no value returned${raw:+ ($raw)}"
    elif [ "$got" = "$2" ]; then
        pass "$1 = $got"
    else
        fail "$1 = $got, expected $2"
    fi
}
# The first three are booleans in Hyprland 0.56, so they read "true", not "1".
opt "input:touchpad:tap-to-click"         true
opt "input:touchpad:disable_while_typing" true
opt "general:allow_tearing"               true
opt "general:border_size"                 1
opt "decoration:rounding"                 0
opt "misc:vrr"                            3
opt "render:direct_scanout"               2
opt "input:kb_layout"                     us,ru

# --- wallpaper ---------------------------------------------------------------
# hyprpaper changed its config format in 0.8.4; this is why it is checked.
# hyprctl 0.56 knows only "wallpaper" and "listactive" for hyprpaper; the old
# "listloaded" is gone. listactive prints one "<monitor>: <path>" per monitor.
section "wallpaper"
active=$(hyprctl hyprpaper listactive 2>&1)
if printf '%s\n' "$active" | grep -q '^eDP-1: '; then
    pass "$(printf '%s\n' "$active" | grep '^eDP-1: ')"
elif [ -z "$active" ]; then
    fail "hyprpaper runs but shows no wallpaper - check the path in hyprpaper.conf"
else
    fail "hyprpaper: $active"
fi

# --- keyboard backlight device ------------------------------------------------
# The one value that differs silently rather than loudly.
section "keyboard backlight"
if need brightnessctl; then
    dev=$(brightnessctl -l 2>/dev/null | grep -oE "'[^']*kbd_backlight'" | tr -d "'" | head -1)
    want=$(grep -oE '[a-z0-9_:-]*kbd_backlight' ~/.config/hypr/hypridle.conf 2>/dev/null | head -1)
    if [ -z "$dev" ]; then
        skip "no kbd_backlight device on this machine"
    elif [ "$dev" = "$want" ]; then
        pass "$dev matches hypridle.conf"
    else
        fail "device is '$dev' but hypridle.conf says '$want' - edit hypridle.conf"
    fi
else
    fail "brightnessctl not installed"
fi

# --- polkit agent --------------------------------------------------------------
# Without it no graphical program can ask for the admin password.
section "polkit agent"
if pgrep -f /usr/lib/hyprpolkitagent/hyprpolkitagent >/dev/null 2>&1; then
    pass "hyprpolkitagent is running"
elif [ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ]; then
    fail "hyprpolkitagent is installed but not running - check the autostart in hyprland.lua"
else
    fail "hyprpolkitagent is not installed"
fi

# --- binaries ------------------------------------------------------------------
section "programs"
missing=""
for b in ghostty fuzzel mako dolphin firefox grim slurp cliphist wl-copy waybar \
         hyprsunset hypridle hyprpaper hyprlock brightnessctl playerctl \
         pavucontrol notify-send asusctl supergfxctl nvim tree-sitter jq \
         nmtui bluetoothctl; do
    need "$b" || missing="$missing $b"
done
[ -z "$missing" ] && pass "all present" || fail "missing:$missing"

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono"; then
    pass "JetBrainsMono Nerd Font Mono installed"
else
    fail "JetBrainsMono Nerd Font Mono missing - install ttf-jetbrains-mono-nerd"
fi

# --- asus layer ----------------------------------------------------------------
section "asus"
if need supergfxctl; then
    out=$(supergfxctl -g 2>/dev/null) \
        && pass "supergfxctl -g -> $out" \
        || fail "supergfxctl -g failed - is supergfxd running?"
else
    fail "supergfxctl not installed"
fi
if need asusctl; then
    # asusctl 6.5 prints four lines here; only the first names the active profile.
    out=$(asusctl profile get 2>/dev/null | awk '/^Active profile/{print $NF}')
    [ -n "$out" ] \
        && pass "asusctl profile get -> $out" \
        || fail "asusctl profile get returned nothing - is asusd running?"
else
    fail "asusctl not installed"
fi

# --- left to a human -------------------------------------------------------------
section "needs you"
skip "launch a game: idle_inhibit holds the screen, immediate tears without artefacts"
skip "leave it idle 15 minutes and confirm it suspends"
skip "close the lid: it must lock, sleep, and wake to the lock screen"
skip "switch supergfxctl Hybrid <-> Integrated; the session must come up in both"

section "result"
if [ "$fails" -eq 0 ]; then
    printf '  all checks passed\n'
else
    printf '  %d check(s) failed\n' "$fails"
fi
exit $(( fails > 0 ))
