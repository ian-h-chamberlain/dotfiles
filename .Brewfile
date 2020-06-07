# ==============================================================================
# Homebrew-provided taps
# ==============================================================================
tap "homebrew/bundle"
tap "homebrew/cask-fonts"
tap "homebrew/cask"
tap "homebrew/core"


# ==============================================================================
# Third-party taps
# ==============================================================================


# ==============================================================================
# Regular packages
# ==============================================================================

# Bourne-Again SHell, a UNIX command interpreter
brew "bash"

# Programmable completion for Bash 4.1+
brew "bash-completion@2"

# Informative, fancy bash prompt for Git users
brew "bash-git-prompt"

# Clone of cat(1) with syntax highlighting and Git integration
brew "bat"

# User-friendly launcher for Bazel
brew "bazelisk"

# Statistics utility to count lines of code
brew "cloc"

# Cross-platform make
brew "cmake"

# Reimplementation of ctags(1)
brew "ctags"

# Get a file from an HTTP, HTTPS or FTP server
brew "curl"

# GNU Emacs text editor
brew "emacs"

# User-friendly command-line shell for UNIX-like operating systems
brew "fish"

# Distributed revision control system
brew "git"

# Git extension for versioning large files
brew "git-lfs"

# Improved top (interactive process viewer)
brew "htop"

# Curses-based tool for viewing and analyzing log files
brew "lnav"

# Ambitious Vim-fork focused on extensibility and agility
brew "neovim"

# Python version management
brew "pyenv"

# Pyenv plugin to manage virtualenv
brew "pyenv-virtualenv"

# The Rust toolchain installer
brew "rustup-init"

# Static analysis and lint tool, for (ba)sh scripts
brew "shellcheck"

# Programatically correct mistyped console commands
brew "thefuck"

# Internet file retriever
brew "wget"

# Yet Another Dotfiles Manager
brew "yadm"


# ==============================================================================
# Casks
# ==============================================================================

# Install in home dir instead of /Applications
cask_args appdir: "~/Applications" if `yadm config local.class`.strip == "personal"

# Torrent client
cask "deluge"

# Text editor
cask "emacs"

# Preferred font for fixed-width text e.g. terminal + editors
cask "~/.config/brew/casks/font-input.rb"

# Image editor
cask "gimp"

# Password manager
cask "keepassxc"

# Text editor
cask "visual-studio-code"

# X11 compatibility layer
cask "xquartz"
