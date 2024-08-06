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
    PATH="${config.homebrew.brewPrefix}":$PATH ${cleanupCmd}
  '';

  homebrew = {
    enable = true;

    onActivation = {
      extraFlags = [
        # Suppress "Using XYZ" messages to highlight only changed packages
        "--quiet"
      ];
      # TODO: zap would be nice but I'm scared of accidentally losing settings or
      # data. AppCleaner hopefully will help with this a bit too.
      # Also might be nice to have a "check" or "fail" option that just fails activation
      # instead of uninstalling stuff... https://github.com/Homebrew/homebrew-bundle/issues/1418
      cleanup = "uninstall";
    };

    global.autoUpdate = false;

    taps = [
      "d12frosted/emacs-plus"
      "ian-h-chamberlain/dotfiles"
      {
        name = "kde-mac/kde";
        clone_target = "https://invent.kde.org/packaging/homebrew-kde.git";
      }
    ];

    brews = [
      "d12frosted/emacs-plus/emacs-plus@29"
      "ian-h-chamberlain/dotfiles/neovim@0.9.5"
      "pre-commit"
      "pyenv-virtualenv" # doesn't seem to be in nixpkgs
      "pyenv" # use same installation method as pyenv-virtualenv
      "wakeonlan"
    ];

    caskArgs = {
      # In theory by the time I add a cask to this list, I trust it enough to avoid
      # quarantining. Global `brew install --cask`s will still be quarantined.
      no_quarantine = true;
    };

    # TODO: "archgpt/tap/insomnium" # Checksum failure on install...
    casks = [
      "appcleaner"
      "bettertouchtool"
      "betterzip"
      "darkmodebuddy"
      "disk-inventory-x"
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
    ];

    masApps = {
      Amphetamine = 937984704;
    };
  };
}
