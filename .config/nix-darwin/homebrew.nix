{ self, lib, config, host, pkgs, ... }:
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
    #!/usr/bin/env bash
    ${x86_64-brew.config.system.activationScripts.homebrew.text}
  '';
in
{
  imports = [
    ./vscode.nix
  ] ++ self.lib.existingPaths [
    ./homebrew/${host.class}.nix
    ./homebrew/${host.name}.nix
    ./homebrew/${host.system}.nix
  ];

  # Inject the x86_64 brew activation into our top-level darwin activation
  # Technically `activationScripts.homebrew` is kind of an implementation detail
  # but it's probably fine... see e.g. https://github.com/LnL7/nix-darwin/pull/664
  system.activationScripts.homebrew.text = lib.mkAfter
    ''
      arch -x86_64 ${activateHomebrew};
    '';

  homebrew = {
    enable = true;

    onActivation = {
      extraFlags = [
        # Suppress "Using XYZ" messages to primarily highlight changed packages
        "--quiet"
      ];
      # TODO: zap would be nice but I'm scared of accidentally losing settings or
      # data. AppCleaner hopefully will help with this a bit too.
      # Also might be nice to have a "check" or "fail" option that just fails activation
      # instead of uninstalling stuff...

      # cleanup = "uninstall";
    };

    global.autoUpdate = false;

    taps = [
      {
        # Most taps get pulled in implicitly by cask/formula names, but
        # this one being on gitlab means it needs an explicit entry.
        name = "kde-mac/kde";
        clone_target = "https://invent.kde.org/packaging/homebrew-kde.git";
      }
      "d12frosted/emacs-plus"
      "ian-h-chamberlain/dotfiles"
    ];

    # TODO: most of ~/.config/brew/Brewfile is probably available in nixpkgs already
    brews = [
      "d12frosted/emacs-plus/emacs-plus@29"
      "pre-commit"

      # pyenv-virtualenv does not seem to be in nixpkgs, and having them installed
      # the same way as each other seems to make more sense than separate installations
      "pyenv"
      "pyenv-virtualenv"

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
      "ian-h-chamberlain/dotfiles/font-monaspace"
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
