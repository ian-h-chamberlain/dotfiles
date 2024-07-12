{ config, pkgs, lib, pkgsUnstable, ... }:
{

  # TODO: may need to use lix-installer to upgrade to a non-beta version:
  # https://git.lix.systems/lix-project/lix/issues/411
  # https://git.lix.systems/lix-project/lix/issues/431
  # https://git.lix.systems/lix-project/lix-installer/issues/10
  nix.package = pkgs.lix;

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

  home.packages = with pkgs; [
    # Fish completions + path setup stuff, needed since I'm not letting
    # home-manager do all the shell setup for me. Most notably, this creates
    # ~/.nix-profile/etc/profile.d/nix.fish - don't remove without a replacement!
    config.nix.package

    cacert
    docker-compose
    git-crypt
    pkgsUnstable.lnav
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
