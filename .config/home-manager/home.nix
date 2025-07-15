{
  self,
  config,
  lib,
  pkgs,
  homeDirectory ? "/home/${config.home.user}",
  host,
  ...
}:
let
  inherit (pkgs) stdenv;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  nix-homebrew = (self.inputs or { }).nix-homebrew or null;
  user = config.home.user or "ianchamberlain";

  # ugh this will be different between nixos and others won't it

  packpathDirs = config.programs.neovim.finalPackage.packpathDirs;
  finalPackdir = (pkgs.neovimUtils.packDir packpathDirs);
  packdirPackage =
    pkgs.runCommand "pack" { } # bash
      ''
        mkdir -p $out/opt/nvim/
        ${lib.getExe pkgs.xorg.lndir} -silent ${finalPackdir} $out/opt/nvim/
      '';

  # NOTE: this might be able to work from any calling file using ${self} somehow
  mkRelative = path: lib.path.removePrefix ../. path;

  mkSymlink = file: mkOutOfStoreSymlink (lib.path.append /${config.xdg.configHome} (mkRelative file));
in
{
  imports = self.lib.existingPaths [
    ./macos-defaults.nix
    ./default-apps.nix
    ./direnv
    ./helix
    # ./firefox.nix # TODO

    # This is kinda janky but I guess it works...
    # https://github.com/nix-community/home-manager/issues/1906
    ./${if host.wsl then "" else "non-"}wsl
    ./${host.class}
  ];

  # These defaults are mainly just for nixOS which I haven't converted to flakes yet
  # so it needs to be deprioritized with mkDefault to avoid conflict with e.g. darwinModules
  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault homeDirectory;

  # TODO: maybe try using
  # https://github.com/nix-community/home-manager/issues/3276#issuecomment-2052599524
  # to workaround https://github.com/nix-community/home-manager/issues/4198
  # but need to source sessionVariables somehow without
  # https://github.com/nix-community/home-manager/issues/5602

  nix.settings = {
    repl-overlays = "${config.xdg.configHome}/nix/repl-overlays.nix";
    # Use extra- to avoid overwriting settings from nix-darwin/nixos
    extra-experimental-features = [
      "pipe-operator"
      "lix-custom-sub-commands"
    ];

    # TODO: try out default-flake
    # https://github.com/nix-community/home-manager/issues/5753
  };
  # Annoying, idk how to resolve this...
  # https://github.com/nix-community/home-manager/issues/5753
  nix.checkConfig = false;

  # https://github.com/nix-community/home-manager/issues/2033
  news = {
    display = "silent";
    entries = lib.mkForce [ ];
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    bat = {
      enable = true;
      # Not working for whatever reason:
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };
    fd.enable = true;
    fish.enable = true;
    git.enable = true;
    gpg.enable = true;
    helix = {
      enable = true;
      package = pkgs.helix;
      # See ./helix/default.nix
      vimMode = false;
      settings.theme = "monokai";
    };
    htop.enable = true;
    neovim = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/137829
      package = pkgs.neovim-unwrapped;

      plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (
          # Include default bundled languages as well here:
          # https://github.com/nvim-treesitter/nvim-treesitter/issues/3092
          plugins: with plugins; [
            bash
            c
            comment
            cpp
            css
            csv
            diff
            dockerfile
            fish
            go
            html
            javascript
            json
            lua
            markdown
            nix
            printf
            python
            query
            regex
            rust
            toml
            typescript
            vim
            vimdoc
            xml
          ]
        ))
      ];
      extraWrapperArgs = [
        "--add-flags"
        # Move my configs to the front of path in order to pick up treesitter queries etc.
        # before the vim-pack-dir ones provided by nixpkgs / withPlugins
        (lib.escapeShellArgs [
          # TODO: maybe these should use config.xdg.configHome
          "--cmd"
          "set runtimepath-=~/.config/nvim"
          "--cmd"
          "set runtimepath^=~/.config/nvim"
          "--cmd"
          "set packpath-=~/.config/nvim"
          "--cmd"
          "set packpath^=~/.config/nvim"
        ])
      ];
    };
    ripgrep.enable = true;
    jq.enable = true;
    wezterm.enable = true;
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
    "git/config".enable = false;
    "wezterm/wezterm.lua".enable = false;

    "helix/config.toml".source = lib.mkForce (mkSymlink ./helix/config.toml);

    # See ../flake.nix for why this exists. It would be nice to make it be a
    # relative path instead, but I guess this works, and it's needed since the
    # filename ".git" is special to git and can't be checked into the repo.
    ".git".source = mkOutOfStoreSymlink "/${config.xdg.dataHome}/yadm/repo.git";
  };

  # TODO: this should probably be handled by nix-homebrew and/or `brew completions link`
  xdg.dataFile = lib.mkIf stdenv.isDarwin {
    "fish/vendor_completions.d/brew.fish".source =
      "${nix-homebrew.inputs.brew-src}/completions/fish/brew.fish";
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
      pinentryPackage = lib.mkIf (!host.wsl) pkgs.pinentry-curses;
    };
  };

  # See services.gpg-agent - manually set up conf file on macos instead
  home.file = {
    ".gnupg/gpg-agent.conf" = lib.mkIf stdenv.isDarwin {
      text = ''
        # Use nix-packaged pinentry-mac
        pinentry-program    ${pkgs.pinentry_mac}/bin/pinentry-mac
        # Set TTL to 5 days for GPG passphrase prompt
        default-cache-ttl   432000
        max-cache-ttl       432000
      '';
    };
  };

  home.packages =
    with pkgs;
    [
      buildifier
      # bacon # also available as a flake if I need bleeding-edge
      clang-tools
      difftastic
      docker
      docker-compose
      docker-credential-helpers
      file
      packdirPackage # so I can reference it for Lua-LSP etc.
      gh
      git-crypt
      git-lfs
      go
      home-manager # omitted when nix-darwin module is in use, even with programs.home-manager enabled
      hyperfine
      lua-language-server
      mergiraf
      mold
      ncurses # Newer version including tset/reset, can understand tmux terminfo etc.
      nil
      nixpkgs-fmt
      nixfmt-rfc-style
      openssh
      pre-commit
      python3
      rustup
      shellcheck
      thefuck
      tmux
      tree
      lnav
      # nixd # Failing to build in nixos-unstable, I don't really use it anymore anyway
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
    ]
    ++ lib.optionals stdenv.isLinux [
      pinentry-curses
      comby # failing to build on macOS: https://github.com/NixOS/nixpkgs/issues/359193
    ]
    ++ lib.optionals host.wsl [
      podman # use podman --remote to access host WSL podman instance
    ];

  home.sessionVariables = lib.mkIf (!stdenv.isDarwin) (
    self.lib.sslCertEnv "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  );

  home.stateVersion = "20.09";
}
