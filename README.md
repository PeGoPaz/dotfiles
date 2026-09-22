# dotfiles

Monochrome Hyprland setup for an ASUS TUF A14 (FA401GM) running CachyOS.
Off-black greyscale with a single purple accent.

## Credits

Based on [shyamjames/dotfiles-black-minimal](https://github.com/shyamjames/dotfiles-black-minimal)
by Shyam James - the original colour scheme, structure and Waybar layout come
from that project. Heavily modified since: NVIDIA and ASUS-specific setup,
Ghostty instead of kitty, fuzzel instead of rofi, mako instead of dunst.

## Usage

```bash
git clone git@github.com:PeGoPaz/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow hypr ghostty waybar fuzzel mako nvim
```