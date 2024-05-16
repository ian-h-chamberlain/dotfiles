{ config, pkgs, lib, ... }:

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Programs with builtin home-manager support. Notably, `fish` and `neovim`
    # are set in home.packages instead so I can just use my existing config/plugins
    # instead of having to migrate everything over to nix.
    bat.enable = true;
    git.enable = true;
    gpg.enable = true;
    htop.enable = true;
    ripgrep.enable = true;
    thefuck.enable = true;
    tmux.enable = true;
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
    docker-compose
    fish
    git-crypt
    neovim
    shellcheck
    tree
    tmux
    unzip
    yadm
  ];

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
