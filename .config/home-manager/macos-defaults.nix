{ self, lib, pkgs, config, osConfig, host, ... }:
let
  cfg = config.targets.darwin;
in
{
  imports = [
    ./macos-defaults/keyboard-shortcuts.nix
  ] ++ self.lib.existingPaths [
    ./macos-defaults/${host.class}.nix
    ./macos-defaults/${host.name}.nix
    ./macos-defaults/${host.system}.nix
  ];

  # Workaround for https://github.com/NixOS/nixpkgs/issues/181427
  # Predeclaring these allows one to depend on the other.
  # See https://nixos.org/manual/nixos/stable/index.html#sec-freeform-modules
  # TODO: maybe upstream to home-manager...
  options.targets.darwin.defaults = {
    "com.apple.AppleMultitouchTrackpad" = lib.mkOption {
      type = with lib.types; attrsOf anything;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = lib.mkOption {
      type = with lib.types; attrsOf anything;
    };
  };

  config.targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
    # region macOS defaults
    currentHostDefaults = {
      NSGlobalDomain = {
        NSStatusItemSelectionPadding = 10;
        NSStatusItemSpacing = 6;
        AppleEnableSwipeNavigateWithScrolls = 0;
      };
    };

    defaults = {
      NSGlobalDomain = { };

      # https://apple.stackexchange.com/a/444202
      "com.apple.security.authorization".ignoreArd = true;

      "com.apple.spaces" = {
        app-bindings = {
          "net.hovancik.stretchly" = "AllSpaces";
          "org.keepassxc.keepassxc" = "AllSpaces";
        };
      };

      "com.apple.screencapture" = {
        location = "~/Downloads";
      };

      "com.apple.calculator" = {
        SeparatorsDefaultsKey = 1;
        ViewDefaultsKey = "Scientific";
        Programmer_InputMode = 10; # 16 == hexadecimal
      };

      # "com.apple.AppleMultitouchTrackpad" = { };
      # "com.apple.driver.AppleBluetoothMultitouch.trackpad" =
      #   config.targets.darwin.defaults."com.apple.AppleMultitouchTrackpad";

      "com.apple.ncprefs" = {
        # TODO: if I can figure out how, this would be handy to configure.
        # Something like this, probably feasible with something like
        # `echo $JSON | plutil -convert binary1 - -o - | base64`:
        /*
          dnd_prefs = base64Encode (binaryPlist {
            dndDisplayLock = false;
            dndDisplaySleep = true;
            dndMirrored = false;
            facetimeCanBreakDND = false;
            repeatedFacetimeCallsBreaksDND = false;
          });
            */
      };

      "com.apple.AppleMultitouchTrackpad" = {
        Clicking = 1;
        TrackpadThreeFingerDrag = 1;
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 0;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" =
        cfg.defaults."com.apple.AppleMultitouchTrackpad";

      # TODO: possibly automatic `killall Dock` like nix-darwin:
      # https://github.com/LnL7/nix-darwin/blob/0413754b3cdb879ba14f6e96915e5fdf06c6aab6/modules/system/defaults-write.nix#L111-L112
      "com.apple.dock" = {
        mineffect = "suck";
        magnification = true;
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        showhidden = true;
        tilesize = 60;
        largesize = 72;

        showAppExposeGestureEnabled = 1;
        showMissionControlGestureEnabled = 1;

        persistent-others =
          let
            inherit (self.lib.dock) folder;
            homeDir = config.home.homeDirectory;
            appdir = self.lib.unwrapOr "/Applications" osConfig.homebrew.caskArgs.appdir;
          in
          [
            (folder "${homeDir}/Library/Application Support")
            (folder appdir)
            (folder homeDir)
            (folder "${homeDir}/Documents")
            (folder "${homeDir}/Downloads")
          ];
      };

      #endregion

      #region per-app defaults

      "com.googlecode.iterm2" = {
        PrefsCustomFolder = "~/.config/iterm2";
        LoadPrefsFromCustomFolder = true;
      };

      "com.hegenberg.BetterTouchTool" = {
        BTTAutoLoadPath = "~/.config/btt/Default.bttpreset";
      };

      "com.DanPristupov.Fork" = let homeDir = config.home.homeDirectory; in {
        customGitInstancePath = "${homeDir}/.config/yadm/forkgit/bin/git";
        defaultSourceFolder = "${homeDir}/Documents";
        diffFontName = "MonaspiceArNF-Light";
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
        <<<<<<< HEAD
          } // keyboardShortcuts (with keys; {
          "File->Open..." = [ cmd alt "o" ];
        "Hide Untracked Files" = [ ctrl "h" ];
        "Open in Terminal" = [ cmd shift "x" ];
        "Open" = [ cmd "o" ];
      });
      =======
      };
      >>>>>>> ce53d896fd91e62bdf5023aae14579924eee5bd6

        "com.github.xor-gate.syncthing-macosx" = {
        StartAtLogin = 1;
      };

      "com.if.Amphetamine" = {
        "Icon Style" = 2;
      };

      #endregion
    };
  };
}
