# dotfiles

Monochrome Hyprland setup for an ASUS TUF A14 (FA401GM) running CachyOS.
Off-black greyscale with a single purple accent.

Hardware this is written for: Ryzen AI 9 465 with Radeon 880M (iGPU) plus NVIDIA
RTX 5060 (dGPU), a single internal panel `eDP-1` at 2560x1600@165, Limine as the
bootloader. 

## Credits

Based on [shyamjames/dotfiles-black-minimal](https://github.com/shyamjames/dotfiles-black-minimal)
by Shyam James - the original colour scheme, structure and Waybar layout come from
that project. Heavily rewritten since: single-panel A14 setup, hybrid-GPU handling,
Ghostty, fuzzel, mako, ranger and a LazyVim starter.

No LICENSE file is included. The upstream project ships none, so its author retains
all rights and this fork cannot grant a licence it does not hold.

## Read this before you stow anything

CachyOS ships its own Hyprland setup through `/etc/skel`, so a fresh account already
has `~/.config/hypr/hyprland.conf`, `~/.config/waybar/` and `~/.config/mako/`. Two
things follow from that.

**Stow will refuse to overwrite the waybar and mako configs.** They are real files,
not symlinks, so move them aside first. The `hypr`, `ghostty`, `fuzzel` and `nvim`
packages do not collide - this config is `hyprland.lua` where CachyOS ships
`hyprland.conf`, and CachyOS ships wofi rather than fuzzel.

**Rolling back needs no backup.** Hyprland loads `hyprland.lua` if it exists and
falls back to `hyprland.conf` otherwise, and this repo never touches the `.conf`.
So `stow -D hypr` alone puts CachyOS's own working config back.

Do this in order:

1. Boot CachyOS on its stock config and confirm a Hyprland session comes up.
2. Check the version this config is aimed at:
   ```bash
   hyprctl version
   ```
   It was written against 0.56.2. A different major version is worth a look at the
   wiki before continuing.
3. Move the two colliding configs aside:
   ```bash
   mv ~/.config/waybar ~/.config/waybar.stock
   mv ~/.config/mako ~/.config/mako.stock
   ```
4. Now stow:
   ```bash
   git clone https://github.com/PeGoPaz/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow hypr ghostty waybar fuzzel mako nvim
   ```
5. Log out and back in, then run `~/.config/hypr/scripts/check.sh`.

### What this config takes over from CachyOS

Replacing `hyprland.conf` with `hyprland.lua` drops everything CachyOS set in it.
Two of those settings are worth having and are carried over here: `misc:vrr = 2`
and `render:direct_scanout`. Three are deliberately left behind - window snapping,
window swallowing, and CachyOS's four-finger gesture set.

Worth knowing: CachyOS's own config still sets `dwindle:pseudotile`, which Hyprland
0.56.2 no longer has. Stock configs go stale too.

### If the config has errors

Hyprland does not refuse to start over a bad config. It comes up, and lists the
errors in an overlay on screen, so you can read them without leaving the session.

If an error is early enough that no keybind got registered, Hyprland also trips
emergency mode and binds three keys of its own:

| Key | Action | Works here? |
|---|---|---|
| `SUPER + M` | exit Hyprland | yes |
| `SUPER + R` | `hyprland-run` | yes, if installed |
| `SUPER + Q` | first known terminal | probably |

`SUPER + Q` searches a hardcoded list - `kitty`, `alacritty`, `foot`, `wezterm`,
`gnome-terminal`, `xterm` - which Ghostty is not on. CachyOS uses alacritty as its
stock terminal, so it is most likely already installed and the key will work, but
nothing declares it as a dependency, so do not count on it. `SUPER + M` and a TTY
on `Ctrl+Alt+F2` are the reliable ways out.

To put CachyOS's config back from a TTY, remove this one - the `.conf` underneath
was never touched, and Hyprland falls back to it:

```bash
cd ~/dotfiles && stow -D hypr
```

If `stow -D` did not clear the symlink:

```bash
rm -f ~/.config/hypr/hyprland.lua
```

`hyprctl configerrors` prints the same list as the overlay. The log has more:

```bash
tail -60 ~/.local/share/hyprland/hyprland.log
```

## Assumptions that only the hardware can confirm

Every config in this repo has been checked key by key against the source of the
version the repositories actually ship - Hyprland 0.56.2, hyprlock 0.9.6, hypridle
0.1.8, hyprpaper 0.8.4, hyprsunset 0.4.0, Waybar 0.15.0, mako 1.11, fuzzel 1.15.
Ghostty's config is validated by `ghostty +validate-config`, and the Neovim setup
was installed and started for real.

What that checking cannot settle is anything that depends on the machine. These four
are the remainder, and `check.sh` tests all of them:

| Assumption | How to check | If it is wrong |
|---|---|---|
| `2560x1600@165` is accepted on `eDP-1` | `hyprctl monitors` | Edit the monitor block |
| Keyboard backlight device `asus::kbd_backlight` | `brightnessctl -l` | One line in `hypridle.conf` |
| Output shape of `supergfxctl -g` and `asusctl profile -p` | Run them by hand | Waybar module shows empty |
| `immediate` tears cleanly on NVIDIA | Launch something from Steam | Drop the `immediate` rule |
| The lid switch is named `Lid Switch` | `hyprctl devices` | Rename it in the two `switch:` binds |

Checking names is not the same as proving the whole config loads. It caught two real
breakages that were inherited from upstream - hyprpaper's config format and three
hyprlock keys that no longer exist - but only a first boot proves the rest.

## First boot checklist

Run the script. It checks everything that can be checked automatically and exits
non-zero if anything failed:

```bash
~/.config/hypr/scripts/check.sh
```

It verifies the panel mode and scale, that the touchpad and layout options really
took effect, that hyprpaper actually loaded a wallpaper, that the keyboard backlight
device matches what `hypridle.conf` names, that every program the configs call is
installed, and that `supergfxctl` and `asusctl` answer.

Three things it marks `SKIP`, because they need you:

1. Launch a game from Steam - the screen must not blank, and tearing must have no
   artefacts. If it does, drop the `immediate` rule.
2. Leave the laptop idle for 15 minutes and confirm it suspends.
3. Switch supergfxctl Hybrid to Integrated and back. The session must come up in
   both - that is the check that no GPU is pinned anywhere.

Worth eyeballing too: `Alt+Shift` switches `us`/`ru`, and `hyprctl hyprsunset
temperature` should match the time of day.

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
