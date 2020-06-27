{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
in

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # For use with git, git-crypt, etc.
    gpg.enable = true;

    neovim.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 14400;
    maxCacheTtl = 14400;
    pinentryFlavor = "curses";
  };

  home.packages = with pkgs; [
    # Need to use unstable for fish 3.1.x
    unstable.fish

    git-crypt
    lsb-release
    pinentry-curses
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
