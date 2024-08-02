{ config
, lib
, pkgs
, user ? "ianchamberlain"
, unstable ? import <nixos-unstable> { }
, nix-homebrew ? null
, homeDirectory ? "/home/${config.home.user}"
, ...
}:
let
  inherit (pkgs) stdenv;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  imports = [
    ./macos-defaults.nix
  ];

  # These defaults are mainly just for nixOS which I haven't converted to flakes yet
  # so it needs to be deprioritized with mkDefault to avoid conflict with e.g. darwinModules
  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault homeDirectory;

  nix.extraOptions = ''
    repl-overlays = ${config.xdg.configHome}/nix/repl-overlays.nix
  '';

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    fd.enable = true;
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
    jq.enable = true;
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

  # TODO: this should probably be handled by nix-homebrew and/or `brew completions link`
  xdg.dataFile = lib.mkIf stdenv.isDarwin {
    "fish/vendor_completions.d/brew.fish".source = "${nix-homebrew.inputs.brew-src}/completions/fish/brew.fish";
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

    # For commit signing, git-crypt, etc.
    gpg-agent = {
      # https://github.com/nix-community/home-manager/issues/3864
      # TODO: it would be nice to setup gpg-agent.conf on macOS properly
      # during activation... Maybe nix-darwin has something?
      enable = stdenv.isLinux;

      defaultCacheTtl = 432000; # 5 days
      maxCacheTtl = 432000;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };

  home.packages = with pkgs; [
    buildifier
    cacert
    clang-tools
    docker-credential-helpers
    docker
    docker-compose
    gh
    go
    git-crypt
    git-lfs
    nil
    nixpkgs-fmt
    openssh
    python3
    rustup
    shellcheck
    thefuck
    tmux
    tmux.terminfo
    tree
    unstable.lnav
    unstable.nixd
    unzip
    watch
    yadm

    # Fish completions + path setup stuff, needed since I'm not letting
    # home-manager do all the shell setup for me. Most notably, this creates
    # ~/.nix-profile/etc/profile.d/nix.fish - don't remove without a replacement!
    #
    # This may cause trouble on nixOS but I can't remember why...
    config.nix.package
  ]
  ++ lib.optionals stdenv.isDarwin [
    # Might also consider pinentry-touchid
    pinentry_mac
    swiftdefaultapps
    colima
  ];

  # TODO: https://github.com/nix-community/home-manager/issues/5602
  home.sessionVariables = {
    # https://github.com/NixOS/nixpkgs/issues/66716
    # https://github.com/NixOS/nixpkgs/issues/210223
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SYSTEM_CERTIFICATE_PATH = "${config.home.sessionVariables.SSL_CERT_FILE}";
    GIT_SSL_CAINFO = "${config.home.sessionVariables.SSL_CERT_FILE}";

    # This doesn't really seem to work as expected for e.g. `tset`, etc.
    # Linking into /etc/ or /usr/share or something might work...
    TERMINFO_DIRS = ":${config.home.profileDirectory}/share/terminfo";
    TERMINFO = "${config.home.profileDirectory}/share/terminfo";
  };

  home.stateVersion = "20.09";
}
