{
  self,
  lib,
  host,
  pkgs,
  config,
  ...
}:
let
  # TODO: would be nice to just reuse the existing written brewfile instead of
  # writing my own, but it seems like nix is clever enough to unify them.
  # Either exposing it in nix-darwin or upstreaming the check itself should work.
  brewfileFile = pkgs.writeText "Brewfile" config.homebrew.brewfile;

  # Uses https://github.com/Homebrew/homebrew-bundle/pull/1420
  # in order to fail if any packages are missing from the brewfile.
  cleanupCmd = builtins.concatStringsSep " " (
    # Basically copied from ${nix-darwin}/modules/homebrew.nix:
    lib.optional (!config.homebrew.onActivation.autoUpdate) "HOMEBREW_NO_AUTO_UPDATE=1"
    ++ [ "brew bundle cleanup --file='${brewfileFile}'" ]
  );
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
  homebrew = {
    enable = true;

    onActivation = {
      extraFlags = [
        # Suppress "Using XYZ" messages to highlight only changed packages
        "--quiet"
      ];
      # TODO: might be nice to get back to:
      # cleanup = "check";
    };

    global.autoUpdate = false;

    taps = [
      "ian-h-chamberlain/dotfiles"
      {
        name = "kde-mac/kde";
        clone_target = "https://invent.kde.org/packaging/homebrew-kde.git";
      }
    ];

    brews = [
      "curl"
      "docker-buildx"
      "ian-h-chamberlain/dotfiles/neovim@0.9.5"
      "mas"
      "ninja"
      "llvm"
      "pre-commit"
      "python@3.12"
      "pyenv-virtualenv" # doesn't seem to be in nixpkgs
      "pyenv" # use same installation method as pyenv-virtualenv
      "wakeonlan"
      "tree-sitter"
      "gnu-sed"
    ];

    caskArgs = {
      # In theory by the time I add a cask to this list, I trust it enough to avoid
      # quarantining. Global `brew install --cask`s will still be quarantined.
      no_quarantine = true;
    };

    casks = [
      "appcleaner"
      "bettertouchtool"
      "betterzip"
      "darkmodebuddy"
      "disk-inventory-x"
      "emacs" # Seems like whatever problems I was using d12frosted/emacs-plus for got fixed...
      "firefox"
      "firefox@developer-edition"
      "flux"
      "font-monaspace-nerd-font"
      "fork"
      "gimp"
      "google-chrome"
      "hex-fiend"
      "ian-h-chamberlain/dotfiles/font-monaspace"
      "instantview"
      "iterm2"
      "kde-mac/kde/kdeconnect"
      "keepassxc"
      "logitech-g-hub"
      "proxy-audio-device"
      "qlimagesize"
      "qlmarkdown"
      "qlvideo"
      "quicklook-json"
      "spotify"
      "signal"
      "stretchly"
      "syncthing"
      "syntax-highlight"
      "visual-studio-code"
      "vlc"
      "wacom-tablet"
      "wezterm@nightly"
      "wireshark"
      "xquartz"
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
    # masApps = { Amphetamine = 937984704; };
  };
}
