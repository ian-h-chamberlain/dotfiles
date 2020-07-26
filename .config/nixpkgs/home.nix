{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
in

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # NOTE: Programs must be listed here for fish completion to work!
    bat.enable = true;
    git.enable = true;
    gpg.enable = true;

    # Preferred shell
    fish = {
      enable = true;
      # Need to use unstable for fish 3.1.x
      package = unstable.fish;
    };

    # Preferred editor, including nix highlighting
    neovim = {
      enable = true;

      # Create shell aliases
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # TODO: can this be deduped with ~/.config/nvim/init.vim ?
      extraConfig = ''
        set runtimepath^=~/.vim runtimepath+=~/.vim/after
        let &packpath = &runtimepath
        source ~/.vimrc
      '';

      # Nix syntax highlighting
      plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-fish
      ];
    };
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
  };

  home.packages = with pkgs; [
    docker-compose
    file
    git-crypt
    htop
    pinentry-curses
    shellcheck
    thefuck
    tree
    udevil
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
