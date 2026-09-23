# dotfiles

Monochrome Hyprland setup for an ASUS TUF A14 (FA401GM) running CachyOS.

Off-black greyscale with a single purple accent.

Hardware this is written for: Ryzen AI 9 465 with Radeon 880M (iGPU) plus NVIDIA
RTX 5060 (dGPU), a single internal panel `eDP-1` at 2560x1600@165, Limine as the bootloader. 

## Credits

Based on [shyamjames/dotfiles-black-minimal](https://github.com/shyamjames/dotfiles-black-minimal)
by Shyam James - the original colour scheme, structure and Waybar layout come from that project. Heavily rewritten since: single-panel A14 setup, hybrid-GPU handling Ghostty, fuzzel, mako, Dolphin and a LazyVim starter.

No LICENSE file is included. The upstream project ships none, so its author retains all rights and this fork cannot grant a licence it does not hold.

## Read this before you stow anything

The CachyOS installer's Hyprland choice installs `hyprland`, `dolphin`, `kitty`, `sddm` and the `cachyos-hypr-noctalia` metapackage. That metapackage puts CachyOS's own setup into `/etc/skel`, so a fresh account already has a Lua config at `~/.config/hypr/hyprland.lua` (plus `config/*.lua` and `xdph.conf` next to it) and runs the noctalia shell for its bar, notifications, launcher and password prompts.

**Stow will refuse to overwrite `~/.config/hypr/hyprland.lua`.** It is a real file, not a symlink, so move that one file aside first. Leave `xdph.conf` where it is - it lets
screen sharing remember a permission you already gave - and leave `config/` alone too; this `hyprland.lua` does not load it. Older installs that used the `cachyos-hyprland-settings` package also shipped `~/.config/waybar` and `~/.config/mako`; move those aside if they exist.

**Rolling back means putting that file back.** `stow -D hypr` removes this config and the `.stock` copy goes back in its place. That only brings back a working desktop while noctalia is still installed, so remove CachyOS's stock packages last, once this config has proven itself.

Do this in order:
1. Boot CachyOS on its stock config and confirm a Hyprland session comes up.
2. Check the version this config is aimed at:
   ```bash
   hyprctl version
   ```
   It was written against 0.56.2. A different major version is worth a look at the
   wiki before continuing.
3. Move the colliding files aside:
   ```bash
   mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.stock
   for d in waybar mako; do [ -e ~/.config/$d ] && mv ~/.config/$d ~/.config/$d.stock; done
   ```
4. Now stow:
   ```bash
   git clone https://github.com/PeGoPaz/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow hypr ghostty waybar fuzzel mako nvim
   ```
5. Log out and back in, then run `~/.config/hypr/scripts/check.sh`.

The login screen offers both "Hyprland" and "Hyprland (uwsm-managed)". This config works in either; the uwsm one also picks up CachyOS's `~/.config/uwsm/env`, which sets the cursor theme and Qt theming.

### What this config takes over from CachyOS

Replacing CachyOS's `hyprland.lua` drops everything it set. The two settings worth having match what it uses: `misc:vrr = 3` (adaptive sync for fullscreen games only) and `render:direct_scanout = 2` (auto). Window swallowing and `dwindle:preserve_split` are deliberately left behind.

noctalia is not started, and everything it did has a replacement here: the bar is Waybar, notifications are mako, the launcher is fuzzel, the lock screen is hyprlock, wallpaper is hyprpaper, and the password prompt for graphical programs is `hyprpolkitagent`, started from this config's autostart.

`QT_QPA_PLATFORMTHEME=qt6ct` is set here as well, so Qt programs such as Dolphin look the same in both login sessions. The colours they use are the ones noctalia generated on the first stock boot, from CachyOS's default wallpaper; they stay after noctalia is gone.

### If the config has errors

Hyprland does not refuse to start over a bad config. It comes up, and lists the errors in an overlay on screen, so you can read them without leaving the session.

If an error is early enough that no keybind got registered, Hyprland also trips emergency mode and binds three keys of its own:

| Key | Action | Works here? |
|---|---|---|
| `SUPER + M` | exit Hyprland | yes |
| `SUPER + R` | `hyprland-run` | yes, if installed |
| `SUPER + Q` | first known terminal | yes |

`SUPER + Q` searches a hardcoded list - `kitty`, `alacritty`, `foot`, `wezterm`,
`gnome-terminal`, `xterm` - which Ghostty is not on. kitty is first on it, and the CachyOS installer installs kitty explicitly, so the key opens a terminal. Keep kitty installed for exactly this reason. A TTY on `Ctrl+Alt+F2` is the other way out.

To put CachyOS's config back from a TTY:
```bash
cd ~/dotfiles && stow -D hypr
mv ~/.config/hypr/hyprland.lua.stock ~/.config/hypr/hyprland.lua
```

If `stow -D` did not clear the symlink, `rm -f ~/.config/hypr/hyprland.lua` first.

`hyprctl configerrors` prints the same list as the overlay. The log has more:

```bash
tail -60 ~/.local/share/hyprland/hyprland.log
```

## Assumptions that only the hardware can confirm

Every config in this repo has been checked key by key against the source of the version the repositories actually ship - Hyprland 0.56.2, hyprlock 0.9.6, hypridle 0.1.8, hyprpaper 0.8.4, hyprsunset 0.4.0, Waybar 0.15.0, mako 1.11, fuzzel 1.15. 
Ghostty's config is validated by `ghostty +validate-config`, and the Neovim setup was installed and started for real.

What that checking cannot settle is anything that depends on the machine. These four are the remainder, and `check.sh` tests all of them:

| Assumption | How to check | If it is wrong |
|---|---|---|
| `2560x1600@165` is accepted on `eDP-1` | `hyprctl monitors` | Edit the monitor block |
| Keyboard backlight device `asus::kbd_backlight` | `brightnessctl -l` | One line in `hypridle.conf` |
| Output shape of `supergfxctl -g` and `asusctl profile get` | Run them by hand | Waybar module shows empty |
| `immediate` tears cleanly on NVIDIA | Launch something from Steam | Drop the `immediate` rule |

Checking names is not the same as proving the whole config loads. It has caught real breakages - hyprpaper's config format, three hyprlock keys that no longer exist, and `hyprctl dispatch dpms off` and `hyprctl keyword`, which stop working once Hyprland's config is Lua - but only a first boot proves the rest.

## First boot checklist

Run the script. It checks everything that can be checked automatically and exits non-zero if anything failed:

```bash
~/.config/hypr/scripts/check.sh
```

It verifies the panel mode and scale, that the touchpad, layout and VRR options really took effect, that hyprpaper actually shows a wallpaper, that the keyboard backlight device matches what `hypridle.conf` names, that the polkit agent is running, that every program the configs call is installed, and that `supergfxctl` and `asusctl` answer.

Four things it marks `SKIP`, because they need you:

1. Launch a game from Steam - the screen must not blank, and tearing must have no artefacts. If it does, drop the `immediate` rule.
2. Leave the laptop idle for 15 minutes and confirm it suspends.
3. Close the lid - it must lock, sleep, and wake to the lock screen.
4. Switch supergfxctl Hybrid to Integrated and back. The session must come up in both - that is the check that no GPU is pinned anywhere.

Worth eyeballing too: `Alt+Shift` switches `us`/`ru`, and `hyprctl hyprsunset temperature` should match the time of day.

## Why the GPU is not pinned anywhere

The A14 is a hybrid machine and modes are switched with supergfxctl. The config deliberately does **not** set `AQ_DRM_DEVICES`, `WLR_DRM_DEVICES` or `LIBVA_DRIVER_NAME`: pining the compositor to the NVIDIA node means the session refuses to start once supergfxctl is switched to Integrated, and a fixed VA-API driver breaks on every mode switch. Only mode-agnostic variables are set, and they are harmless when the dGPU is powered down.

## System-level steps that are not in this repository

These live outside `$HOME` and need root, so they are instructions rather than files.

- **`nvidia-open-dkms`.** The RTX 5060 is Blackwell and the proprietary kernel modules do not support that architecture at all. There is no choice here.
- **Kernel parameter `nvidia_drm.fbdev=1`.** With Limine this goes in
  `/etc/default/limine` followed by `limine-update`. On drivers 545 and newer
  `nvidia_drm.modeset=1` is already the default and usually does not need adding.
- **Packages.** All binary packages - nothing here is built from the AUR.
  ```
  hyprland hyprpaper hypridle hyprlock hyprsunset hyprpolkitagent waybar ghostty fuzzel mako dolphin qt6ct firefox grim slurp cliphist wl-clipboard brightnessctl playerctl pavucontrol libnotify asusctl rog-control-center supergfxctl nvidia-prime ttf-jetbrains-mono-nerd neovim tree-sitter-cli gcc git ripgrep fd jq stow
  ```
  `supergfxctl` is not in the Arch repositories. It comes from CachyOS's own signed repository, which is enabled by default on CachyOS, so plain `pacman -S` finds it.
  Worth knowing: upstream supergfxctl has not cut a release since mid-2025. That is a question of project activity, not of the package's integrity.

  Several of these back things the configs already reference: `pavucontrol` is the volume module's click action, `libnotify` provides the `notify-send` used by the screenshot script, `playerctl` drives the media keys, `hyprpolkitagent` is the password prompt, `dolphin` is `SUPER + E`, `qt6ct` themes Qt programs such as Dolphin, and `jq` is what `check.sh` reads the monitor with. The Waybar network and bluetooth modules open `nmtui` and `bluetoothctl`, which CachyOS already installs with NetworkManager and `bluez-utils`. `neovim` runs the LazyVim config; LazyVim needs `git` and a C compiler, its syntax highlighting needs `tree-sitter-cli`, and its file and text search use `fd` and `ripgrep`. `stow` and `git` are what installs this repository in the first place.
- **A wallpaper.** `hyprpaper.conf` points at `~/Pictures/wallpapers/wallpaper.jpg`.
  Images are gitignored, so put your own there.

### Hibernation, if you want it later

`hypridle` suspends after 15 minutes. A plain suspend keeps the disk encryption key in RAM, so it is not a defence against someone with physical access - only hibernation clears it. Making `systemctl suspend-then-hibernate` work needs swap at least as large as RAM, `resume=` in the Limine entry and, on btrfs over LUKS, a `resume_offset`. That is its own task and is deliberately left out of the initial setup. To switch over, change the 900s listener in `hypridle.conf` once hibernation is proven to work by hand.

## Keybindings

`SUPER` is the key with the Windows logo.

**Programs**

| Key | Action |
|---|---|
| `SUPER + Return` | Ghostty |
| `SUPER + E` | Dolphin |
| `SUPER + B` | Firefox |
| `SUPER + A` | fuzzel launcher |
| `SUPER + V` | clipboard history through fuzzel |
| `SUPER + L` | lock |
| `SUPER + Backspace` | power menu - lock, logout, suspend, reboot, shutdown |
| `Print` | screenshot - asks region or full screen, copies it too |
| `SUPER + Shift + W` | reload Waybar |

**Windows**

| Key | Action |
|---|---|
| `SUPER + Q` | close window |
| `SUPER + W` | toggle floating |
| `SUPER + P` | pseudotile - keeps its own size inside its tile |
| `SUPER + arrows` | move focus left, right, up, down |
| `SUPER + left drag` | move window |
| `SUPER + right drag` | resize window |

**Workspaces**

| Key | Action |
|---|---|
| `SUPER + 1` ... `SUPER + 0` | go to workspace 1-10 |
| `SUPER + Shift + 1` ... `0` | move the window to workspace 1-10 |
| `SUPER + scroll` | step through existing workspaces |
| `SUPER + S` | show or hide the scratchpad |
| `SUPER + Shift + S` | send the window to the scratchpad |
| three-finger swipe | step through workspaces |

**Laptop keys** - these also work on the lock screen.

| Key | Action |
|---|---|
| volume keys | up, down, mute, mute microphone |
| brightness keys | up, down |
| media keys | next, previous, play/pause |

**Lid**

| Event | Action |
|---|---|
| close | lock, then sleep - on battery and on AC alike |
| open | the lock screen |

The lid is handled by systemd-logind, not by a Hyprland bind: logind suspends on close, and hypridle's default `inhibit_sleep` holds that sleep back until hyprlock is actually on screen.

## Notes

- Clicking the network icon opens `nmtui` and the bluetooth icon opens `bluetoothctl`, both in Ghostty. Neither needs an extra package.
- `nvim/.config/nvim/lazy-lock.json` is committed on purpose so plugin versions are reproducible on a fresh machine.
