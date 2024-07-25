{ ... }: {
  homebrew = {
    enable = true;

    onActivation = {
      # TODO: zap would be nice but I'm scared of accidentally losing settings or
      # data. AppCleaner hopefully will help with this a bit too
      cleanup = "uninstall";
    };

    global.autoUpdate = false;

    taps = [
      {
        name = "kde-mac/kde";
        clone_target = "https://invent.kde.org/packaging/homebrew-kde.git";
      }
      "d12frosted/emacs-plus"
    ];

    # TODO: most of ~/.config/brew/Brewfile is probably available in nixpkgs already
    brews = [
      "wakeonlan"
      "d12frosted/emacs-plus/emacs-plus@29"
    ];

    casks = [
      "appcleaner"
      # "archgpt/tap/insomnium" # Checksum failure on install...
      "balance-lock"
      "bettertouchtool"
      "betterzip"
      "darkmodebuddy"
      "disk-inventory-x"
      "firefox"
      "flux"
      "font-monaspace"
      "font-monaspace-nerd-font"
      "fork"
      "gimp"
      "google-chrome"
      "hex-fiend"
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
      "slack" # TODO: Work-only
      "stretchly"
      "syncthing"
      "syntax-highlight"
      "termhere"
      "visual-studio-code"
      "vlc"
      "wacom-tablet"
      "wireshark"
      "xquartz"
      "zoom"
    ];

    # TODO: vscodes could be added in here, since nix-darwin doesn't seem to support natively
    extraConfig = "";
  };
}
