inputs @ { config
, lib
, pkgs
, user ? "ianchamberlain"
, unstable ? import <nixos-unstable> { }
, ...
}:
let
  inherit (pkgs) stdenv;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  # These defaults are mainly just for nixOS which I haven't converted to flakes yet
  # so it needs to be deprioritized to avoid conflict with e.g. darwinModules
  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault inputs.homeDirectory or "/home/${config.home.user}";

  nix.extraOptions = ''
    repl-overlays = ${config.xdg.configHome}/nix/repl-overlays.nix
  '';

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    # fd.enable = true;
    fish.enable = true;
    git.enable = true;
    gpg.enable = true;
    htop.enable = true;
    neovim = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/137829
      package = unstable.neovim-unwrapped;
    };
    ripgrep.enable = true;
  };

  # Just use my own configs for these instead of having home-manager generate
  # them. Easier than migrating all of my config over to nix.
  # `source = mkOutOfStoreSymlink ...` would also work here, but generates a
  # warning at switch time that it is symlinking to itself, so this seems better.
  #
  # Maybe could work a little nicer using something like this:
  # https://github.com/nix-community/home-manager/issues/676#issuecomment-1595795685
  xdg.configFile = {
    "fish/config.fish".enable = false;
    "nvim/init.lua".enable = false;

    # See ../flake.nix for why this exists. It would be nice to make it be a
    # relative path instead, but I guess this works, and it's needed since the
    # filename ".git" is special to git and can't be checked into the repo.
    ".git".source = mkOutOfStoreSymlink /${config.xdg.dataHome}/yadm/repo.git;
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
      # TODO: guess this got removed on nixos??
      # pinentryPackage = pkgs.pinentry-curses;
    };
  };

  # TODO: should try to convert these to flake inputs probably
  nixpkgs.overlays = [
    (final: prev: {
      /* TODO
      htop = prev.htop.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "ian-h-chamberlain";
          repo = "htop";
          rev = "feat/non-fkey-menubar";
          sha256 = "";
        };
      });
      #*/
    })
  ];

  home.packages = with pkgs; [
    cacert
    docker-compose
    git-crypt
    git-lfs
    unstable.lnav
    nil
    unstable.nixd
    nixpkgs-fmt
    python3
    rustup
    openssh
    shellcheck
    thefuck
    tree
    tmux
    tmux.terminfo
    unzip
    yadm

    # Fish completions + path setup stuff, needed since I'm not letting
    # home-manager do all the shell setup for me. Most notably, this creates
    # ~/.nix-profile/etc/profile.d/nix.fish - don't remove without a replacement!
    #
    # This may cause trouble on nixOS but I can't remember why...
    config.nix.package
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
