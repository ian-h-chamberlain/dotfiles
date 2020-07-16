# dotfiles

Personal preferences for various tools and applications. Currently supports macOS, CentOS, and NixOS, and is designed to be relatively device-agnostic, although it's probably not perfect.

This repo is designed for use with [yadm](https://yadm.io/). See [their documentation](https://yadm.io/docs/getting_started) for details on how to clone this repo and bootstrap it, but the gist of it is just this:

```shell
yadm clone --bootstrap https://github.com/ian-h-chamberlain/dotfiles.git
```

## High level directory structure

Some commonly-known files/directories omitted for brevity. This list focuses on more unusual/custom configuration and less on documenting more common config files.

* [`.config/`](.config)

  Typical `$XDG_CONFIG_HOME` directory for tools that use it. Also store some custom files/tools in here to give them a common home without increasing the breadth of the directory tree

  * [`btt/`](.config/btt)

    [BetterTouchTool](https://folivora.ai/) presets

  * [`fish/`](.config/fish)

    [fish shell](https://fishshell.com/) configuration, including custom functions, prompt definition, plugins, etc

  * [`iterm2/`](.config/iterm2)

    [iTerm2](https://www.iterm2.com/) preferences. This basically amounts to one giant XML file that doesn't play super nicely with Git and multiple devices, but it's better than not synchronizing it

  * [`nixos/`](.config/nixos)

    Device-specific configurations for [NixOS](https://nixos.org/). This directory is meant to be the source for a symlink to `/etc/nixos` on the target device, and contains some hardware-specific config and system-level settings, which would not typically be found in a dotfiles repo

  * [`nixpkgs/`](.config/nixpkgs)

    More traditional user-level Nix configuration. This could in theory be used to install Nix packages on any OS, but is mostly used for NixOS only

  * [`nvim/`](.config/nvim)

    Neovim configuration. At the moment just sources `.vimrc` for a consistent config between standard Vim and NVim

  * [`vscode/`](.config/vscode)

    Custom-made list of VSCode extensions for simple syncing between devices. `code` provides a decent CLI for installing/listing extensions which are used to read from and update from this dir. Note that `~/.vscode` is used by VSCode itself, so this does not conflict with that

  * [`yadm/`](.config/yadm)

    Core configuration for managing this repo

    * [`alt/`](.config/yadm/alt)

      Alternate files for use with `yadm alt`. These are symlinked into the main tree on a per-device basis, mostly using `yadm config local.class`, but can also use Jinja-like templating or be different per-OS

    * [`hooks/`](.config/yadm/hooks)

      Git hooks for this repo. The pre-commit hook ensures the VSCode extension list is up-to-date when committing

    * [`bootstrap`](.config/yadm/bootstrap)

      The main script to run after cloning this repo. It is designed to be idempotent so that it can also be run after a `yadm pull` to bring the system up-to-date. Mostly macOS specific

    * [`utils.sh`](.config/yadm/utils.sh)

      Helper scripts for use with the bootstrap script and hooks. Designed to be portable with little to no prerequisites, with the exception of `bash`

* [`.git-crypt/`](.emacs.d)

  [git-crypt](https://www.agwa.name/projects/git-crypt/) files for storing sensitive information in this rep.

* [`.lnav/`](.lnav)

  Custom log formats for [lnav](http://lnav.org/)

* [`Library/Application Support/Code/User/`](/Library/Application%20Support/Code/User/)

  [VSCode](https://code.visualstudio.com/) settings for macOS. In theory, other macOS app settings could be checked in to the `Application Support` directory, but so far this is the only useful one

* [`.Brewfile`](.Brewfile)

  List of packages to install with [Homebrew](https://brew.sh/). Since this is basically just Ruby code, it can shell out to `yadm` to conditionally install packages based on OS, `yadm config local.class`, etc.

* [`.gitignore`](.gitignore)

  Ignored files for _this_ repository. This shouldn't be necessary because `yadm` hides untracked files by default, but `yadm git-crypt status` is really slow without ignoring some files.

* [`.gitignore_global`](.gitignore_global)

  User settings for globally ignored files in Git repositories.

* [`README.md`](README.md)

  This file! 😃

All other files not mentioned here are either fairly standard/Google-able or not significant enough to be worth mentioning.
