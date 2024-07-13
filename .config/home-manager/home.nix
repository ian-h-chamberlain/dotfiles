{ config, lib, pkgs, unstable, ... }:
let
  stdenv = pkgs.stdenv;
in {
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
    # Automount disks when plugged in
    # udiskie = {
    #   enable = true;
    #   automount = true;
    #   notify = false;
    #   tray = "never";
    # };

    # syncthing.enable = true;
  } // lib.optionalAttrs stdenv.isLinux {
    # For commit signing, git-crypt, etc.
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 432000; # 5 days
      maxCacheTtl = 432000;
      pinentryPackage = pkgs.pinentry-curses;
    };
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
      });

      htop = prev.htop.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "ian-h-chamberlain";
          repo = "htop";
          rev = "feat/non-fkey-menubar";
          sha256 = "";
        };
      });
     })
  ];

  home.packages = with pkgs; [
    # Fish completions + path setup stuff, needed since I'm not letting
    # home-manager do all the shell setup for me. Most notably, this creates
    # ~/.nix-profile/etc/profile.d/nix.fish - don't remove without a replacement!
    config.nix.package

    cacert
    docker-compose
    git-crypt
    unstable.lnav
    shellcheck
    thefuck
    tree
    tmux
    tmux.terminfo
    unzip
    yadm
  ];

  # TODO: https://github.com/nix-community/home-manager/issues/5602
  home.sessionVariables = {
    # https://github.com/NixOS/nixpkgs/issues/66716
    # https://github.com/NixOS/nixpkgs/issues/210223
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SYSTEM_CERTIFICATE_PATH = "${config.home.sessionVariables.SSL_CERT_FILE}";
    GIT_SSL_CAINFO = "${config.home.sessionVariables.SSL_CERT_FILE}";

    TERMINFO_DIRS = ":${config.home.profileDirectory}/share/terminfo";
  };

  home.stateVersion = "20.09";
}
