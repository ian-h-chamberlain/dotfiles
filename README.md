# dotfiles

Personal preferences for .bashrc, .vimrc, etc. (macOS + CentOS for now, possibly more OSes eventually)

This repo is designed for use with [yadm](https://yadm.io/). See [their documentation](https://yadm.io/docs/getting_started) for how to clone this repo and bootstrap.

## TODO items

### Untracked files / apps

* [ ] .clang-format ?
* [x] iTerm2 configuration, however that will work
* [x] SSH, see [encrypted files](#Encrypted-files)
* [-] Other apps in `~/Library/Application Support` (BTT, keepassxc, etc.)
* [ ] Consider checking in keepassXC db? Drive or similar auto-sync is nicer

### Hooks

#### Pre-commit

* [x] Update vscode extension list
* [ ] Linting/autoformatting for relevant files?
* [x] Shellcheck?

#### Post-pull

* [ ] ~~Run bootstrap script~~ Less problematic to force manual bootstrap
* [x] Submodule update, although gitconfig should take care of this

### Alt files

* [x] Gitconfig
* [x] SSH config

### Encrypted files

* [x] Investigate security (GPG, worth using `git-crypt`, etc.)
* [x] Purge/encrypt sensitive files
* [x] SSH keys
* [x] SSH config
