{ config, pkgs, lib, ... }:

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    git.enable = true;
    gpg.enable = true;
  };

  services = {
    # For commit signing, git-crypt, etc.
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 432000; # 5 days
      maxCacheTtl = 432000;
      pinentryFlavor = "curses";
    };

    # Automount disks when plugged in
    udiskie = {
      enable = true;
      automount = true;
      notify = false;
      tray = "never";
    };

    syncthing.enable = true;
  };

  home.packages = with pkgs; [
    docker-compose
    file
    fish
    git-crypt
    htop
    keepassxc
    neovim
    pinentry-curses
    ripgrep
    shellcheck
    thefuck
    tree
    tmux
    unzip
    yadm
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ianchamberlain";
  home.homeDirectory = "/home/ianchamberlain";

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
