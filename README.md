# dotfiles

Monochrome Hyprland setup for an ASUS TUF A14 (FA401GM) running CachyOS.
Off-black greyscale with a single purple accent.

Hardware this is written for: AMD Radeon 890M (iGPU) plus NVIDIA RTX 5060 (dGPU),
a single internal panel `eDP-1` at 2560x1600@165, Limine as the bootloader.

## Credits

Based on [shyamjames/dotfiles-black-minimal](https://github.com/shyamjames/dotfiles-black-minimal)
by Shyam James - the original colour scheme, structure and Waybar layout come from
that project. Heavily rewritten since: single-panel A14 setup, hybrid-GPU handling,
Ghostty, fuzzel, mako, ranger and a LazyVim starter.

No LICENSE file is included. The upstream project ships none, so its author retains
all rights and this fork cannot grant a licence it does not hold.

## Read this before you stow anything

The Hyprland config is written in Lua, which is the official format since Hyprland
0.55 (hyprlang `.conf` is deprecated upstream). It was written without access to the
machine, so **field names in the Lua API are an assumption, not a verified fact**. A
wrong key name means Hyprland does not start - on a freshly installed laptop that is
a bad first impression. Do this in order:

1. Boot CachyOS on its stock config and confirm a Hyprland session comes up.
2. Keep a known-good copy:
   ```bash
   cp ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.stock
   mkdir -p ~/.config/stock-backup
   cp -r ~/.config/waybar ~/.config/mako ~/.config/fuzzel ~/.config/stock-backup/ 2>/dev/null
   ```
3. Check the version this config is aimed at:
   ```bash
   hyprctl version
   ```
   If the major version differs from 0.55+, re-read the wiki before continuing.
4. Only now:
   ```bash
   git clone https://github.com/PeGoPaz/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow hypr ghostty waybar fuzzel mako nvim
   ```
5. Log out and back in.

### If the session does not come up

Switch to a TTY with `Ctrl+Alt+F2`, log in, and undo it:

```bash
cd ~/dotfiles && stow -D hypr
cp ~/.config/hypr/hyprland.lua.stock ~/.config/hypr/hyprland.lua
```

If `stow -D` did not clear the symlink:

```bash
rm -f ~/.config/hypr/hyprland.lua
cp ~/.config/hypr/hyprland.lua.stock ~/.config/hypr/hyprland.lua
```

The cause is in the log - a Lua field error names the line and the key:

```bash
journalctl --user -b -p err | tail -40
tail -60 ~/.local/share/hyprland/hyprland.log
```

## Assumptions that only the hardware can confirm

None of these could be tested before the laptop existed. Each is also marked with an
`UNVERIFIED` comment at the place it appears in the config.

| Assumption | How to check | If it is wrong |
|---|---|---|
| Lua API field names (`hl.monitor`, `touchpad`, `window_rule`) | Hyprland log on first start | Session will not start - roll back as above |
| `2560x1600@165` is accepted on `eDP-1` | `hyprctl monitors` | Edit the monitor block |
| Touchpad keys `tap_to_click` / `disable_while_typing` | Hyprland log | Highest-risk guess in the file; hyprlang spells one of them with hyphens |
| Keyboard backlight device `asus::kbd_backlight` | `brightnessctl -l` | One line in `hypridle.conf` |
| `hyprsunset.conf` profile blocks | `hyprctl hyprsunset temperature` | Needs a recent hyprsunset; the rest still works |
| Output of `supergfxctl -g` and `asusctl profile -p` | Run them by hand | Waybar module shows empty |
| `immediate` tears cleanly on NVIDIA | Launch something from Steam | Drop the `immediate` rule |

## First boot checklist

1. `hyprctl monitors` - `eDP-1` reports 2560x1600@165, logical size 1600x1000.
2. `brightnessctl -l` - confirm the keyboard backlight device name, fix `hypridle.conf`.
3. `supergfxctl -g` and `asusctl profile -p` - the Waybar modules show mode and profile.
4. Switch supergfxctl Hybrid to Integrated and back. The session must come up in both.
   This is the check that no GPU is pinned anywhere.
5. `Alt+Shift` switches between the `us` and `ru` layouts.
6. Touchpad: tap to click, natural scroll, no stray clicks while typing.
7. Launch a game from Steam: the screen does not blank, and tearing has no artefacts.
8. `hyprctl hyprsunset temperature` matches the time of day.
9. Leave it idle for 15 minutes and confirm it suspends.

## Why the GPU is not pinned anywhere

The A14 is a hybrid machine and modes are switched with supergfxctl. The config
deliberately does **not** set `AQ_DRM_DEVICES`, `WLR_DRM_DEVICES` or
`LIBVA_DRIVER_NAME`: pinning the compositor to the NVIDIA node means the session
refuses to start once supergfxctl is switched to Integrated, and a fixed VA-API
driver breaks on every mode switch. Only mode-agnostic variables are set, and they
are harmless when the dGPU is powered down.

## System-level steps that are not in this repository

These live outside `$HOME` and need root, so they are instructions rather than files.

- **`nvidia-open-dkms`.** The RTX 5060 is Blackwell and the proprietary kernel modules
  do not support that architecture at all. There is no choice here.
- **Kernel parameter `nvidia_drm.fbdev=1`.** With Limine this goes in
  `/etc/default/limine` followed by `limine-update`. On drivers 545 and newer
  `nvidia_drm.modeset=1` is already the default and usually does not need adding.
- **Packages.** All binary packages - nothing here is built from the AUR.
  ```
  hyprland hyprpaper hypridle hyprlock hyprsunset waybar ghostty fuzzel mako ranger
  firefox grim slurp cliphist wl-clipboard brightnessctl playerctl pavucontrol
  libnotify asusctl rog-control-center supergfxctl nvidia-prime
  ttf-jetbrains-mono-nerd
  ```
  `supergfxctl` is not in the Arch repositories. It comes from CachyOS's own signed
  repository, which is enabled by default on CachyOS, so plain `pacman -S` finds it.
  Worth knowing: upstream supergfxctl has not cut a release since mid-2025. That is a
  question of project activity, not of the package's integrity.

  Three of these back things the configs already reference: `pavucontrol` is the volume
  module's click action, `libnotify` provides the `notify-send` used by the screenshot
  script, and `playerctl` drives the media keys.
- **A wallpaper.** `hyprpaper.conf` points at `~/Pictures/wallpapers/wallpaper.jpg`.
  Images are gitignored, so put your own there.

### Hibernation, if you want it later

`hypridle` suspends after 15 minutes. A plain suspend keeps the disk encryption key
in RAM, so it is not a defence against someone with physical access - only hibernation
clears it. Making `systemctl suspend-then-hibernate` work needs swap at least as large
as RAM, `resume=` in the Limine entry and, on btrfs over LUKS, a `resume_offset`.
That is its own task and is deliberately left out of the initial setup. To switch over,
change the 900s listener in `hypridle.conf` once hibernation is proven to work by hand.

## Keybindings

`SUPER` is the modifier.

| Key | Action |
|---|---|
| `Return` | Ghostty |
| `Q` | close window |
| `E` | ranger in Ghostty |
| `B` | Firefox |
| `A` | fuzzel |
| `V` | clipboard history through fuzzel |
| `L` | lock |
| `W` | toggle floating |
| `S` / `Shift+S` | scratchpad / move to scratchpad |
| `Backspace` | power menu |
| `Print` | screenshot (region or full screen) |
| `1`-`0` | workspaces, `Shift` to move the window |
| `Shift+W` | reload Waybar |

## Notes

- The Waybar bluetooth module shows state but has no click action - a GUI would mean
  another package. Add `"on-click"` to the module if you install one.
- `nvim/.config/nvim/lazy-lock.json` is committed on purpose so plugin versions are
  reproducible on a fresh machine.
