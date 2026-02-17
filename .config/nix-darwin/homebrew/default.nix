{
  self,
  lib,
  host,
  pkgs,
  config,
  ...
}:
let
  # Technically this could be a different store path than the real
  # one used for checking but its contents should be the same at least.
  brewfileFile = pkgs.writeText "Brewfile" config.homebrew.brewfile;
in
{
  imports = [
    ./vscode.nix
  ]
  ++ self.lib.existingPaths [
    ./${host.class}.nix
    ./${host.name}.nix
    ./${host.system}.nix
  ];

  nix-homebrew.autoMigrate = true;

  system.checks.text = lib.mkBefore ''
    echo >&2 Checking Brewfile: ${brewfileFile}
  '';
  homebrew = {
    enable = true;

    onActivation = {
      extraFlags = [
        # Suppress "Using XYZ" messages to highlight only changed packages
        "--quiet"
      ];
      # TODO: might be nice to get back to:
      cleanup = "check";
    };

    global.autoUpdate = false;

    taps = [
      "ian-h-chamberlain/dotfiles"
      "welfvh/tap"
      {
        name = "kde-mac/kde";
        clone_target = "https://invent.kde.org/packaging/homebrew-kde.git";
      }
    ];

    brews = [
      "curl"
      "docker-buildx"
      "gnu-sed"
      "ian-h-chamberlain/dotfiles/neovim@0.9.5"
      "imagemagick"
      "latexindent"
      "llvm"
      "mas"
      "ninja"
      "pre-commit"
      "pyenv" # use same installation method as pyenv-virtualenv
      "pyenv-virtualenv" # doesn't seem to be in nixpkgs
      "python@3.12"
      "texlive"
      "tree-sitter"
      "wakeonlan"
    ];

    caskArgs = {
      appdir = "${config.users.users.${host.user}.home}/Applications";
      # In theory by the time I add a cask to this list, I trust it enough to avoid
      # quarantining. Global `brew install --cask`s will still be quarantined.
      no_quarantine = true;
    };

    casks = [
      "android-platform-tools"
      "appcleaner"
      "bettertouchtool"
      "betterzip"
      "bitcoin-core"
      "darkmodebuddy"
      "disk-inventory-x"
      "emacs-app"
      "firefox"
      "firefox@developer-edition"
      "floorp"
      "flux-app"
      "font-monaspace"
      "font-monaspace-var"
      "fork"
      "gimp"
      "google-chrome"
      "hex-fiend"
      "instantview"
      "iterm2"
      "kde-mac/kde/kdeconnect"
      "keepassxc"
      "logitech-g-hub"
      "mullvad-vpn"
      "proxy-audio-device"
      "qlimagesize"
      "qlmarkdown"
      "quicklook-json"
      "signal"
      "skim"
      "spotify"
      "stretchly"
      "syncthing-app"
      "syntax-highlight"
      "visual-studio-code"
      "vlc"
      "waterfox"
      "welfvh/tap/daylight-mirror"
      "wezterm@nightly"
      "wireshark-app"
      "xquartz"
      "zed@preview"
      "zoom"
      {
        # Even though this is installed from nixpkgs for ../home-manager/default-apps.nix,
        # that install doesn't include the preference pane, and the cask does.
        name = "swiftdefaultappsprefpane";
        # Skip the binary to avoid any confusion between the two.
        args.no_binaries = true;
      }
    ];

    # Seems to be broken currently:
    masApps = {
      Amphetamine = 937984704;
    };
  };
}
