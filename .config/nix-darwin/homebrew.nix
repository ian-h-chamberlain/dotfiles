{ self, lib, config, pkgs, ... }:

let
  # Wow, this is hella messy and probably not really how you're supposed to use this,
  # but by importing the nix-darwin module and passing it all the right args it looks
  # like we can get x86 brew to install a different set of packages.
  #
  # I probably ought to do this with some custom options or something instead
  # of just a let-binding but this will do for now...
  x86_64-brew = import "${self.inputs.nix-darwin}" {
    nixpkgs = self.inputs.nixpkgs;
    inherit pkgs;

    # Not sure if this is really necessary, but it feels more "right". Maybe
    # I can omit the explicit brewPrefix with it in place, or something...
    system = "x86_64-darwin";

    configuration.homebrew = {
      inherit (config.homebrew) enable global;
      inherit (config.homebrew.onActivation) cleanup;

      brewPrefix = "/usr/local/bin";
      brews = [
        "bazelisk"
      ];
    };
  };

  # HACK: this relies on the fact that macOS /bin/bash is a universal executable
  # instead of using Nix's bash which is not. I suppose I could ask for nixpkgs'
  # x86_64 version here instead, but the script is simple enough not to need it.
  activateHomebrew = pkgs.writeScript "activate-x86_64-brew" ''
    #!/bin/bash
    ${x86_64-brew.config.system.activationScripts.homebrew.text}
  '';
in
{
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

  # Inject the x86_64 brew activation into our top-level darwin activation
  # Order 2000 so this step comes after nix-homebrew sets up /usr/local (@1500)
  system.activationScripts.extraUserActivation.text = lib.mkOrder 2000 ''
    arch -x86_64 ${activateHomebrew};
  '';
}
