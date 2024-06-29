{ config, pkgs, lib, ... }:

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    fd.enable = true;
    fish.enable = true;
    git.enable = true;
    gpg.enable = true;
    htop.enable = true;
    neovim.enable = true;
    ripgrep.enable = true;
    thefuck.enable = true;
  };

  # Just use my own configs for these instead of having home-manager generate
  # them. Easier than migrating all of my config over to nix.
  # `source = mkOutOfStoreSymlink ...` would also work here, but generates a
  # warning at switch time that it is symlinking to itself, so this seems better.
  xdg.configFile = {
    "fish/config.fish".enable = false;
    "nvim/init.lua".enable = false;
  };

  services = {
    # For commit signing, git-crypt, etc.
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 432000; # 5 days
      maxCacheTtl = 432000;
      pinentryPackage = pkgs.pinentry-curses;
    };

    # Automount disks when plugged in
    # udiskie = {
    #   enable = true;
    #   automount = true;
    #   notify = false;
    #   tray = "never";
    # };

    # syncthing.enable = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      lnav = prev.lnav.overrideAttrs (_: rec {
        version = "0.12.2";

        # Can't just use an override, since lnav doesn't use finalAttrs pattern:
        # https://github.com/NixOS/nixpkgs/issues/293452
        src = pkgs.fetchFromGitHub {
          owner = "tstack";
          repo = "lnav";
          rev = "v${version}";
          sha256 = "grEW3J50osKJzulNQFN7Gir5+wk1qFPc/YaT+EZMAqs=";
        };

        patches = [];
      });
     })
  ];

  home.packages = with pkgs; [
    cacert
    docker-compose
    git-crypt
    lix # For e.g. fish completions
    lnav
    shellcheck
    tree
    tmux
    tmux.terminfo
    unzip
    yadm
  ];

  # https://github.com/NixOS/nixpkgs/issues/66716
  # https://github.com/NixOS/nixpkgs/issues/210223
  home.sessionVariables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SYSTEM_CERTIFICATE_PATH = "${config.home.sessionVariables.SSL_CERT_FILE}";
    GIT_SSL_CAINFO = "${config.home.sessionVariables.SSL_CERT_FILE}";
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  # TODO: this could be a home.local.nix or something that is a `yadm alt` file
  home.username = "ichamberlain";
  home.homeDirectory = "/Users/ichamberlain";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
