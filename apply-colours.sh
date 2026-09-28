#!/usr/bin/env bash
# Points the files that programs rewrite on their own at the monochrome colour
# schemes. KDE programs and the qt6ct window save kdeglobals and qt6ct.conf by
# writing a new file and renaming it over the old one, which would turn a stow
# symlink back into a plain file, so these files are edited in place instead.
# Safe to run again; run it after changing a colour scheme.
#
#   kdeglobals   colour groups copied from Monochrome.colors
#   qt6ct.conf   color_scheme_path -> qt6ct/colors/monochrome.conf
#   dolphinrc    Dolphin's own colour scheme setting -> Monochrome
#   btop.conf    color_theme -> greyscale, which ships with btop

set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)
scheme="$repo/kde/.local/share/color-schemes/Monochrome.colors"
conf=${XDG_CONFIG_HOME:-$HOME/.config}

# Sets key=value inside [group] of an ini-style file, adding the key or the
# group if missing. The file is rewritten in place, so it keeps its inode.
ini_set() {
    local file=$1 group=$2 key=$3 value=$4 out
    mkdir -p "$(dirname "$file")"
    touch "$file"
    out=$(awk -v g="[$group]" -v k="$key" -v v="$value" '
        function emit()  { print k "=" v; done = 1 }
        function flush() { printf "%s", held; held = "" }
        $0 == g                          { flush(); ingroup = 1; print; next }
        ingroup && /^[[:space:]]*$/      { held = held $0 "\n"; next }
        /^\[/ && ingroup && !done        { emit() }
        /^\[/                            { ingroup = 0 }
        ingroup && index($0, k "=") == 1 { flush(); if (!done) emit(); next }
                                         { flush(); print }
        END { if (!done && !ingroup) print (NR ? "\n" : "") g
              if (!done) emit()
              flush() }
    ' "$file")
    printf '%s\n' "$out" > "$file"
}

# --- kdeglobals ---------------------------------------------------------------
# Drop every colour group (and the stray scheme name noctalia left in
# [General]), then append the scheme's colour groups. Comments and blank lines
# are dropped and groups get one blank line between them, so reruns do not
# pile up empty lines.
kdeglobals="$conf/kdeglobals"
touch "$kdeglobals"
out=$(
    awk '
        /^\[/ { skip = /^\[(Colors:|ColorEffects:|WM\])/; general = ($0 == "[General]")
                if (!skip && n++) print "" }
        skip || /^[[:space:]]*$/ || /^#/ { next }
        general && /^Name=/ { next }
        { print }
    ' "$kdeglobals"
    awk '
        /^\[/ { keep = /^\[(Colors:|ColorEffects:|WM\])/; if (keep) print "" }
        keep && !/^[[:space:]]*$/ && !/^#/
    ' "$scheme"
)
printf '%s\n' "$out" | sed '/./,$!d' > "$kdeglobals"
ini_set "$kdeglobals" General ColorScheme Monochrome

# --- qt6ct --------------------------------------------------------------------
qt6ct="$conf/qt6ct/qt6ct.conf"
ini_set "$qt6ct" Appearance color_scheme_path "$conf/qt6ct/colors/monochrome.conf"
ini_set "$qt6ct" Appearance custom_palette true

# --- Dolphin ------------------------------------------------------------------
# Without a scheme of its own, Dolphin falls back to Breeze or Breeze Dark when
# it is not running under Plasma, ignoring qt6ct. The value is the scheme's
# file name without .colors.
ini_set "$conf/dolphinrc" UiSettings ColorScheme Monochrome

# --- btop ---------------------------------------------------------------------
# btop.conf is "key = value" with no groups. btop saves its settings on exit,
# so a running btop would write the old theme back.
btop="$conf/btop/btop.conf"
if pgrep -x btop >/dev/null; then
    echo "btop is running - quit it and run this again, or it keeps its old theme" >&2
fi
mkdir -p "$(dirname "$btop")"
touch "$btop"
if grep -q '^color_theme' "$btop"; then
    sed -i 's|^color_theme *=.*|color_theme = "greyscale"|' "$btop"
else
    printf 'color_theme = "greyscale"\n' >> "$btop"
fi

echo "applied - restart Qt, KDE and GTK programs to see it"
