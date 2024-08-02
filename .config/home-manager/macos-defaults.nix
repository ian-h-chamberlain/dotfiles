{ self, lib, pkgs, config, osConfig, ... }:
{
  targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
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

      "com.apple.screencapture" = {
        location = "~/Downloads";
      };

      "com.apple.calculator" = {
        SeparatorsDefaultsKey = 1;
        ViewDefaultsKey = "Scientific";
        Programmer_InputMode = 10; # 16 == hexadecimal
      };

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

      # TODO: killall dock like nix-darwin:
      # https://github.com/LnL7/nix-darwin/blob/0413754b3cdb879ba14f6e96915e5fdf06c6aab6/modules/system/defaults-write.nix#L111-L112
      # Maybe also try to restart other apps too?
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

      "com.if.Amphetamine" = {
        "Icon Style" = 2;
      };

      #endregion
    };
  };
}
