# Dotfiles

- Zsh
- Tmux
- LunarVim
- Kitty

## Installation

- Clone this repository in your **home directory**.

```bash
git clone https://github.com/syndg/dotfiles.git
```

- Install [stow](https://www.gnu.org/software/stow/manual/stow.html) using a package manager of your choice or based on your Linux/Mac distro.

```bash
# For Debian-based distros
sudo apt install stow

# For Arch-based distros
sudo pacman -S stow

# For MacOS
brew install stow
```

- Run `stow <appName>` to install the respective dotfiles.

For example, if you want to install the zsh config files, run:

```bash
stow zsh
```

## Install LunarVim

**MAKE SURE YOU CLONE THIS REPO IN YOUR HOME DIRECTORY**

Otherwise stow wont be able to symlink the config files to the right place.

Install LunarVim from [here](https://www.lunarvim.org/docs/installation)

The installation is pretty simple using the official script, but if you still wanna refer to a video tutorial, check out this one:
[LunarVim Installation](https://www.youtube.com/watch?v=sFA9kX-Ud_c)

To install my LunarVim config files, first clone **this repository** and run the following commands in your **home directory**:

```bash
# home directory
rm -rf ~/.config/lvim
cd dotfiles
stow lvim
```

### What this config contains:

- Codeium AI for code auto-completion
- Different plugins for color highlighting, smooth scrolling and more.
- Different color-schemes that you can choose from.
- A few custom keybindings.
- Relative line numbers enabled by default.

#### Codeium Setup

For Codeium to work, you need to do the following steps:

- Head over to [Codeium's website](https://codeium.com/) and create an account.
- Install LunarVim and install my config files.
- After the installation, run lvim.
- While in normal mode enter the command, `:Codeium Auth`
- You'll be redirected to Codeium's website for authentication and you'll get an API key which you have to paste it in lvim.
- Voila you're done.

Since the `<tab>` key is already taken by lvim for LSP completions, I have configured Codeium to use `<CTRL>+g` for appending the completions.
