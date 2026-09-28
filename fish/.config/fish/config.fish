source /usr/share/cachyos-fish-config/cachyos-config.fish

# CachyOS's config greets every new shell with fastfetch; an empty greeting
# overrides it. It has to come after the source line above.
function fish_greeting
end

export PATH="$HOME/.local/bin:$PATH"
