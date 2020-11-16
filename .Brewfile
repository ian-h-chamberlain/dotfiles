# ==============================================================================
# Homebrew-provided taps
# ==============================================================================

tap "homebrew/bundle"
tap "homebrew/cask-fonts"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/services"

# ==============================================================================
# Third-party/custom taps
# ==============================================================================

tap "ian-h-chamberlain/dotfiles"
tap "nektos/tap"
tap "srkomodo/tap"

# ==============================================================================
# Casks
# ==============================================================================

=begin
TODO add Mac App Store apps:
    - Amphetamine
    - AppCleaner
    - XCode

Maybe also DTerm (would require custom cask, but tbh don't really use it anyway)

=end

case `yadm config local.class`.strip

when "personal"
    # Install in home dir instead of /Applications
    cask_args appdir: "~/Applications"

    # NOTE: uses pkg installer, will always install to /Applications
    # VPN client
    cask "nordvpn"

when "work"
    # Productivity / chat app
    cask "slack"

    # Packet capture tool
    cask "wireshark"
end

# Fixes issues with macOS audio becoming unbalanced
cask "balance-lock"

# Keyboard shortcut + window management tool
cask "bettertouchtool"

# Text + voice chat client
cask "discord"

# Docker for macOS Desktop
cask "docker"

# Text editor
cask "emacs"

# Web browser
cask "firefox"

# GUI for git
cask "fork"

# Image editor
cask "gimp"

# Preferred font for fixed-width text e.g. terminal + editors
cask "ian-h-chamberlain/dotfiles/font-input"

# Vector graphics drawing tool
cask "inkscape"

# Helper app for REST queries
cask "insomnia"

# Terminal emulator
cask "iterm2"

# LaTeX editor and toolchain
cask "mactex"

# Password manager
cask "keepassxc"

# Encrypted messaging platform
cask "signal"

# Music streaming
cask "spotify"

# File synchronization
cask "syncthing"

# Open Terminal directly to a folder from Finder
cask "termhere"

# Text editor
cask "visual-studio-code"

# X11 compatibility layer
cask "xquartz"


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

# Formatting tools for C, C++, Obj-C, Java, JavaScript, TypeScript
brew "clang-format"

# Statistics utility to count lines of code
brew "cloc", args: ["HEAD"]

# Cross-platform make
brew "cmake"

# GNU File, Shell, and Text utilities
brew "coreutils"

# Static analysis of C and C++ code
brew "cppcheck"

# Reimplementation of ctags(1)
brew "ctags"

# Get a file from an HTTP, HTTPS or FTP server
brew "curl", args: ["with-libssh2"]

# User-friendly command-line shell for UNIX-like operating systems
brew "fish"

# GNU debugger
brew "gdb"

# Distributed revision control system
brew "git"

# Enable transparent encryption/decryption of files in a git repo
brew "git-crypt"

# Git extension for versioning large files
brew "git-lfs"

# Open source programming language to build simple/reliable/efficient software
brew "go"

# GNU Pretty Good Privacy (PGP) package
brew "gpg2"

# Graph visualization software from AT&T and Bell Labs
brew "graphviz"

# Improved top (interactive process viewer)
brew "htop"

# Package manager for the Lua programming language
brew "luarocks"

# Curses-based tool for viewing and analyzing log files
brew "lnav", args: ["HEAD"]

# Simple tool to make locally trusted development certificates
brew "mkcert"

# Run GitHub Actions locally
brew "nektos/tap/act"

# Ambitious Vim-fork focused on extensibility and agility
brew "neovim", args: ["HEAD"]

# OpenBSD freely-licensed SSH connectivity tools
brew "openssh"

# Perl compatible regular expressions library
# NOTE: this is a dependency of lnav and may need to be upgraded to HEAD at some point
brew "pcre"

# Pinentry for GPG on Mac
brew "pinentry-mac"

# Python version management
brew "pyenv"

# Pyenv plugin to manage virtualenv
brew "pyenv-virtualenv"

# Search tool like grep and The Silver Searcher
brew "ripgrep"

# The Rust toolchain installer
brew "rustup-init"

# Static analysis and lint tool, for (ba)sh scripts
brew "shellcheck"

# An automatic updater for ShadowFox
brew "srkomodo/tap/shadowfox-updater"

# Programatically correct mistyped console commands
brew "thefuck"

# Terminal multiplexer
brew "tmux"

# Display directories as trees (with optional color/HTML output)
brew "tree"

# Vi 'workalike' with many additional features
brew "vim"

# Internet file retriever
brew "wget"

# Yet Another Dotfiles Manager
brew "yadm"


# ==============================================================================
# Packages that are work-specific or personal-only
# ==============================================================================

case `yadm config local.class`.strip

when "personal"
    # Nothing yet...

when "work"
    # Collection of portable C++ source libraries
    brew "boost@1.55"

    # C++ library for C++/Python2 interoperability
    brew "boost-python"

    # Cross-platform make (older version in custom tap)
    brew "ian-h-chamberlain/dotfiles/cmake"

    # Binary-decimal and decimal-binary routines for IEEE doubles
    brew "double-conversion"

    # Serialization library for C++, supporting Java, C#, and Go
    brew "flatbuffers", args: ["build-from-source"]

    # GNU compiler collection
    brew "gcc@7"

    # Application-level logging library
    brew "glog"

    # library to access smi mib information
    brew "libsmi"

    # GNOME XML library
    brew "libxml2"

    # Next-gen compiler infrastructure
    brew "llvm@6"

    # Implements SNMP v1, v2c, and v3, using IPv4 and IPv6
    brew "net-snmp"

    # Protocol buffers (Google's data interchange format)
    brew "protobuf"

    # Standard unix software packaging tool
    brew "rpm"

    # Rich and complete approach to parallelism in C++
    brew "tbb"
end
