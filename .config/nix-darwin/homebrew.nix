{ self, system, config, ... }: {
  imports = [
    ./vscode.nix
  ];

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
      "d12frosted/emacs-plus/emacs-plus@29"

      # pyenv-virtualenv does not seem to be in nixpkgs, and having them installed
      # the same way as each other seems to make more sense than separate installations
      "pyenv"
      "pyenv-virtualenv"

      "wakeonlan"
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
  };

  # TODO: it might be possible here to instantiate *another* nix-darwin system
  # using a custom brewPrefix for x86_64, and just append its homebrew activation
  # script to the one built by the main nix-darwin module. Is this a bad idea? maybe.
  #
  # Something like this, although literally this gets an error:
  # `The option `homebrew.onActivation.brewBundleCmd' is read-only, but it's set multiple times.`
  /*
    system.activationScripts.extraUserActivation.text =
    let
      x86_64-brew = self.inputs.nix-darwin.lib.darwinSystem
        {
          inherit system;
          modules = [
            {
              homebrew = {
                inherit (config.homebrew) enable onActivation global;
                brewPrefix = "/usr/local/bin";
              };
            }
          ];
        };
    in
    ''
      ${x86_64-brew.config.system.activationScripts.homebrew.text}
    '';
  # */
}
