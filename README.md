# dotfiles

Personal preferences for .bashrc, .vimrc, etc. (macOS + CentOS for now, possibly more OSes eventually)

This repo is designed for use with [yadm](https://yadm.io/). See [their documentation](https://yadm.io/docs/getting_started) for how to clone this repo and bootstrap.

## TODO items

### Untracked files / apps

* [ ] .clang-format ?
* [ ] iTerm2 configuration, however that will work
* [ ] SSH, see [encrypted files](#Encrypted-files)
* [ ] Other apps in `~/Library/Application Support` (BTT, keepassxc, etc.)
* [ ] Consider checking in keepassXC db? Drive or similar auto-sync is nicer

### Casks / App Store apps

* [ ] Google Drive
* [ ] Amphetamine + Amphetamine enhancer
* [ ] Balance Lock
* [ ] BetterTouchTool (uses license)
* [ ] Bowtie (is this even needed anymore?)
* [ ] Discord
* [ ] DTerm (probably requires custom tap)
* [ ] Fork (probably requires custom tap. Also should buy + use license)
* [ ] Spotify
* [ ] TermHere
* [ ] XCode + command line tools

### Hooks

#### Pre-commit

* [ ] Update vscode extension list
* [ ] Linting/autoformatting for relevant files?
* [ ] Shellcheck?

#### Post-pull

* [ ] Run bootstrap script? Must be idemptotent
* [ ] Submodule update, although gitconfig should take care of this

### Alt files

* [ ] Gitconfig
* [ ] Possibly SSH config

### Encrypted files

* [ ] Investigate security (GPG, worth using `git-crypt`, etc.)
* [ ] Purge/encrypt sensitive files:
  * `fish` functions with passwords/IP addresses hardcoded?
  * Any scripts that depend on i95 structure potentially
  * Double-check gitconfig
  * Double-check termux files
* [ ] SSH keys
* [ ] SSH config
