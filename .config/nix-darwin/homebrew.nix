{ self, lib, host, pkgs, config, ... }:
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
    ++ [ "brew bundle cleanup --file='${brewfileFile}' --no-lock" ]
  );
in
{
  imports = [
    ./vscode.nix
  ] ++ self.lib.existingPaths [
    ./homebrew/${host.class}.nix
    ./homebrew/${host.name}.nix
    ./homebrew/${host.system}.nix
  ];

  # Hmm... no other checks seem to care about $checkActivation,
  # but this check will always fail if action was needed, meaning
  # `config.homebrew.cleanup` will never be used. I guess it might really make
  # sense to define this as an alternative to `cleanup = "uninstall" instead of
  # a complement to it?
  system.checks.text = ''
    if test ''${checkActivation:-0} -eq 1; then
        PATH="${config.homebrew.brewPrefix}":$PATH ${cleanupCmd}
    fi
  '';

  homebrew = {
    enable = true;

    onActivation = {
      extraFlags = [
        # Suppress "Using XYZ" messages to highlight only changed packages
        "--quiet"
      ];
      # Zap might be nice but it's scary, for example firefox@nightly zap stanza
      # also deletes stable firefox settings and stuff, so it's probably best
      # to zap on a case-by-case basis instead. AppCleaner should help.
      cleanup = "uninstall";
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
      "ian-h-chamberlain/dotfiles/neovim@0.9.5"
      "pre-commit"
      "pyenv-virtualenv" # doesn't seem to be in nixpkgs
      "pyenv" # use same installation method as pyenv-virtualenv
      "wakeonlan"
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
      "stretchly"
      "syncthing"
      "syntax-highlight"
      "visual-studio-code"
      "vlc"
      "wacom-tablet"
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

    masApps = {
      Amphetamine = 937984704;
    };
  };
}
