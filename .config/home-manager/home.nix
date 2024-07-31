inputs @ { self
, config
, lib
, pkgs
, user ? "ianchamberlain"
, unstable ? import <nixos-unstable> { }
, nix-homebrew
, osConfig
, ...
}:
let
  inherit (pkgs) stdenv;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  # These defaults are mainly just for nixOS which I haven't converted to flakes yet
  # so it needs to be deprioritized with mkDefault to avoid conflict with e.g. darwinModules
  home.username = lib.mkDefault user;
  home.homeDirectory = lib.mkDefault inputs.homeDirectory or "/home/${config.home.user}";

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
  xdg.dataFile = {
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
    cacert
    clang-tools
    docker-credential-helpers
    docker
    docker-compose
    gh
    git-crypt
    git-lfs
    nil
    nixpkgs-fmt
    openssh
    pre-commit
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

  ] ++ lib.optionals stdenv.isDarwin [
    # Might also consider pinentry-touchid
    pinentry_mac
    swiftdefaultapps
    colima
  ];

  #region macOS defaults
  targets.darwin = {
    currentHostDefaults = {
      NSGlobalDomain = {
        NSStatusItemSelectionPadding = 10;
        NSStatusItemSpacing = 6;
      };
    };
    defaults = {
      # https://apple.stackexchange.com/a/444202
      "com.apple.security.authorization".ignoreArd = true;

      "com.apple.spaces" = {
        app-bindings = {
          "net.hovancik.stretchly" = "AllSpaces";
          "org.keepassxc.keepassxc" = "AllSpaces";
        };
      };

      # TODO: killall dock like nix-darwin:
      # https://github.com/LnL7/nix-darwin/blob/0413754b3cdb879ba14f6e96915e5fdf06c6aab6/modules/system/defaults-write.nix#L111-L112
      "com.apple.dock" =
        let
          appdir = self.lib.unwrapOr "/Applications" osConfig.homebrew.caskArgs.appdir;

          path-entry = path: {
            tile-data = {
              file-data = {
                _CFURLString = "${path}";
                _CFURLStringType = 0;
              };
            };
          };

          fileByDir = dir: appName: path-entry "${dir}/${appName}.app";
          app = fileByDir appdir;
          system-app = fileByDir "/System/Applications";
          small-spacer = {
            tile-data = { };
            tile-type = "small-spacer-tile";
          };
        in
        {
          mineffect = "suck";
          magnification = true;
          mru-spaces = false;
          orientation = "bottom";
          show-recents = false;
          showhidden = true;
          tilesize = 60;
          largesize = 72;

          # TODO: this will be different on different systems
          persistent-apps =
            [
              (system-app "System Settings")
              (app "KeePassXC")
              (app "Firefox")
              small-spacer

              (app "Slack")
              (app "Microsoft Teams")
              (app "Visual Studio Code")
              (app "iTerm")
              small-spacer

              (app "Fork")
              # TODO Insomnium
              (app "Emacs")
              small-spacer

              (system-app "Calculator")
              (system-app "Utilities/Activity Monitor")
              (app "Spotify")
            ];

          persistent-others =
            let
              homeDir = config.home.homeDirectory;
              folder = path: lib.recursiveUpdate (path-entry path) {
                tile-data = {
                  # Show as folder icon instead of stack etc.
                  displayas = 1;
                  # Use default appearance for contents, set 2 to force grid here
                  showas = 0;
                };
                tile-type = "directory-tile";
              };
            in
            [
              (folder "${homeDir}/Library/Application Support")
              (folder homeDir)
              (folder appdir)
              (folder "${homeDir}/Documents")
              (folder "${homeDir}/Downloads")
            ];
        };

      #region app defaults

      "com.DanPristupov.Fork" = let homeDir = config.home.homeDirectory; in {
        customGitInstancePath = "${homeDir}/.config/yadm/forkgit/bin/git";
        defaultSourceFolder = "${homeDir}/Documents";
        diffFontName = "MonaspiceArNFM-Light";
        diffFontSize = 12;
        diffIgnoreWhitespaces = 0;
        diffShowChangeMarks = 0;
        diffShowEntireFile = 0;
        diffShowHiddenSymbols = 0;
        disableSyntaxHighlighting = 0;
        fetchAllTags = 0;
        fetchRemotesAutomatically = 0;
        fetchSheetFetchAllRemotes = 0;
        fetchSheetFetchAllTags = 0;
        pageGuideLinePosition = 80;
        pushSheetPushAllTags = 0;
        revisionDiffLayoutMode = 1;
        theme = "system";
        useMonospaceInCommitDescription = 1;

        # I do want to set these, but they seem ... questionably stable as numerical values:
        #externalDiffTool = 7;
        #mergeTool = 7;
        #terminalClient = 1;
      };

      "com.github.xor-gate.syncthing-macosx" = {
        StartAtLogin = 1;
      };

      #endregion
    };
  };

  #endregion

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
