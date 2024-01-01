# Dotfiles

- Zsh
- Tmux
- LunarVim
- Kitty

## Installation

- Clone this repository

```bash
git clone https://github.com/syndg/dotfiles.git
```

- Install [stow](https://www.gnu.org/software/stow/manual/stow.html) using a package manager of your choice or based on your Linux/Mac distro.

```bash
# For Debian-based distros
sudo apt install stow

# For Arch-based distros
sudo pacman -S stow
```

- Run `stow <appName>` to install the respective dotfiles.

For example, if you want to install the LunarVim config files, run:

```bash
stow lunarvim
```
