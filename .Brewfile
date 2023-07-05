# ==============================================================================
# Homebrew-provided taps
# ==============================================================================

tap "homebrew/bundle"
tap "homebrew/cask-drivers"
tap "homebrew/cask-fonts"
tap "homebrew/cask-versions"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/services"
tap "homebrew/test-bot"

# ==============================================================================
# Third-party/custom taps
# ==============================================================================

tap "ian-h-chamberlain/dotfiles"
tap "shihanng/gig"

# ==============================================================================
# Regular packages
# ==============================================================================

# Run your GitHub Actions locally 🚀
brew "act"

# Automatic configure script builder
brew "autoconf"

# Tool for generating GNU Standards-compliant Makefiles
brew "automake"

# Bourne-Again SHell, a UNIX command interpreter
brew "bash"

# Programmable completion for Bash 4.2+
brew "bash-completion@2"

# Informative, fancy bash prompt for Git users
brew "bash-git-prompt"

# Clone of cat(1) with syntax highlighting and Git integration
brew "bat"

# User-friendly launcher for Bazel
brew "bazelisk"

# Formatting tools for C, C++, Obj-C, Java, JavaScript, TypeScript
brew "clang-format"

# Cross-platform make
brew "cmake"

# GNU File, Shell, and Text utilities
brew "coreutils"

# Static analysis of C and C++ code
brew "cppcheck"

# Reimplementation of ctags(1)
brew "ctags"

# Get a file from an HTTP, HTTPS or FTP server
brew "curl"

# Simple, fast and user-friendly alternative to find
brew "fd"

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

# Fast linters runner for Go
brew "golangci-lint"

# GNU Pretty Good Privacy (PGP) package
brew "gnupg"

# Graph visualization software from AT&T and Bell Labs
brew "graphviz"

# Improved top (interactive process viewer)
brew "htop"

# Tools and libraries to manipulate images in many formats
brew "imagemagick"

# Lightweight and flexible command-line JSON processor
brew "jq"

# Curses-based tool for viewing and analyzing log files
brew "lnav"

# Rotates, compresses, and mails system logs
brew "logrotate"

# Simple tool to make locally trusted development certificates
brew "mkcert"

# Ambitious Vim-fork focused on extensibility and agility
brew "neovim"

# OpenBSD freely-licensed SSH connectivity tools
brew "openssh"

# Python version management
brew "pyenv"

# Pyenv plugin to manage virtualenv
brew "pyenv-virtualenv"

# Ruby version manager
brew "rbenv"

# Search tool like grep and The Silver Searcher
brew "ripgrep"

# Rust toolchain installer
brew "rustup-init"

# Static analysis and lint tool, for (ba)sh scripts
brew "shellcheck"

# gitignore file generator
brew "shihanng/gig/gig"

# User interface to the TELNET protocol
brew "telnet"

# Programmatically correct mistyped console commands
brew "thefuck"

# Terminal multiplexer
brew "tmux"

# Display directories as trees (with optional color/HTML output)
brew "tree"

# Vi 'workalike' with many additional features
brew "vim"

# Executes a program periodically, showing output fullscreen
brew "watch"

# Internet file retriever
brew "wget"

# Yet Another Dotfiles Manager
brew "yadm"

# ==============================================================================
# macOS-specific packages (including casks and Mac App Store apps)
# ==============================================================================
if `uname -s` == "Darwin"
  # Mac App Store command-line interface
  brew "mas"

  # Container runtimes on MacOS (and Linux) with minimal setup
  brew "colima"

  # Select default apps for documents and URL schemes on macOS
  brew "duti"

  # Pinentry for GPG on Mac
  brew "pinentry-mac"

  # ==============================================================================
  # Packages that are work-specific or personal-only
  # ==============================================================================

  case `yadm config local.class`.strip

  when "personal"
    # Nothing yet...

  when "work"
    # Collection of portable C++ source libraries
    brew "ian-h-chamberlain/dotfiles/boost@1.69", args: ["--cc=llvm_clang"]

    # C++ library for C++/Python2 interoperability
    brew "boost-python"

    # Format bazel BUILD files with a standard convention
    brew "buildifier"

    # E-books management software
    cask "calibre"

    # Nintendo 3DS emulator
    cask "citra"

    # Server and cloud storage browser
    cask "cyberduck"

    # Binary-decimal and decimal-binary routines for IEEE doubles
    brew "double-conversion"

    # Serialization library for C++, supporting Java, C#, and Go
    brew "flatbuffers", args: ["build-from-source"]

    # GNU compiler collection
    brew "gcc@7"

    # Application-level logging library
    brew "glog"

    # Cross-platform make (older version in custom tap)
    brew "ian-h-chamberlain/dotfiles/cmake"

    # library to access smi mib information
    brew "libsmi"

    # GNOME XML library
    brew "libxml2"

    # Next-gen compiler infrastructure
    brew "llvm"

    # Implements SNMP v1, v2c, and v3, using IPv4 and IPv6
    brew "net-snmp"

    # Framework for managing multi-language pre-commit hooks
    brew "pre-commit"

    # Protocol buffers (Google's data interchange format)
    brew "protobuf@3.6"

    # Standard unix software packaging tool
    brew "rpm"

    # Rich and complete approach to parallelism in C++
    brew "tbb"
  end

  # ==============================================================================
  # Casks
  # ==============================================================================

  case `yadm config local.class`.strip

  when "personal"
    # Install in home dir instead of /Applications
    cask_args appdir: "~/Applications"

    # 3D creation suite
    cask "blender"

    # Voice and text chat software
    cask "discord"

    # NOTE: uses pkg installer, will always install to /Applications
    # VPN client for secure internet access and private browsing
    cask "nordvpn"

    # GCC ARM Embedded
    cask "gcc-arm-embedded"

    # Video game digital distribution service
    cask "steam"
  when "work"
    # OpenVPN client
    cask "pritunl"

    # Team communication and collaboration software
    cask "slack"

    # Team communication and collaboration software
    cask "slite"
  end

  # Application uninstaller
  cask "appcleaner"

  # Compact TeX distribution as alternative to the full TeX Live / MacTeX
  cask "basictex"

  # Prevents audio balance from drifting left or right
  cask "balance-lock"

  # Tool to customize input devices and automate computer systems
  cask "bettertouchtool"

  # Text editor
  cask "emacs"

  # Web browser
  cask "firefox"

  # Screen color temperature controller
  cask "flux"

  # GIT client
  cask "fork"

  # Free and open-source image editor
  cask "gimp"

  # Hex editor focussing on speed
  cask "hex-fiend"

  # Preferred font for fixed-width text e.g. terminal + editors
  cask "ian-h-chamberlain/dotfiles/font-input"

  # Vector graphics editor
  cask "inkscape"

  # HTTP and GraphQL Client
  cask "insomnia"

  # Terminal emulator as alternative to Apple's Terminal app
  cask "iterm2"

  # Password manager app
  cask "keepassxc"

  # Support for Logitech G gear
  cask "logitech-g-hub"

  # Full TeX Live distribution with GUI applications
  cask "mactex"

  # Cross-platform instant messaging application focusing on security
  cask "signal"

  # Music streaming service
  cask "spotify"

  # Real time file synchronization software
  cask "syncthing"

  # Finder extension for opening a terminal from the current directory
  cask "termhere"

  # Virtualizer for x86 hardware
  cask "virtualbox"

  # GUI frontend editor for LaTeX
  cask "texworks"

  # Open-source code editor
  cask "visual-studio-code"

  # Multimedia player
  cask "vlc"

  # Network protocol analyzer
  cask "wireshark"

  # Open-source version of the X.Org X Window System
  cask "xquartz"

  # ==============================================================================
  # Mac App Store apps
  # ==============================================================================

  # Powerful keep-awake utility
  mas "Amphetamine", id: 937984704

  # Stand up and stretch regularly
  mas "StandUp", id: 1439378680

  # Developer Tools
  mas "Xcode", id: 497799835
else
  # ==============================================================================
  # Linux-specific packages (assume != Darwin means linux)
  # ==============================================================================

  # Tool for managing OCI containers and pods
  brew "podman"

  # Access X11 clipboards from the command-line
  brew "xclip"
end
