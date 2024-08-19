{ self, lib, config, pkgs, host, ... }:
{
  imports = [
    ./homebrew.nix
  ];

  # https://github.com/LnL7/nix-darwin/issues/239#issuecomment-719873331
  programs.fish.enable = true;

  # Doesn't seem to work: https://github.com/LnL7/nix-darwin/issues/811
  users.users.${host.user}.shell = pkgs.fish;

  environment = {
    # Basic packages that are needed by nearly everything
    systemPackages = with pkgs; [
      curl
      cacert
    ];

    shells = [ pkgs.fish ];
    loginShell = "${pkgs.fish}/bin/fish";

    etc = let homeDir = config.users.users.${host.user}.home; in {
      # Symlink to dotfiles flake for easier activation
      "nix-darwin/flake.nix".source = "${homeDir}/.config/flake.nix";
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.lix;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #region macOS settings

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    # TODO: figure out where global macOS shortcuts are stored...
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;

      /*
      # https://developer.apple.com/library/content/technotes/tn2450/_index.html
      userKeyMapping = let hex = lib.fromHexString; in [
        # TODO: what is this mapping from?? Need to figure out what other ones
        # from currentHost defaults I care about, if any
        {
          HIDKeyboardModifierMappingSrc = hex "0xFF0100000003";
          HIDKeyboardModifierMappingDst = hex "0x00FF00000003";
        }
      ];
        # */
    };

    # Set up apps after homebrew, so that everything we try to add should be installed
    activationScripts.postUserActivation.text =
      let
        appdir = self.lib.unwrapOr "/Applications" config.homebrew.caskArgs.appdir;
        # TODO: check that each app exists as part of pre-activation checks. It
        # would need to be ordered after homebrew activation but before running applescript
        apps = [
          "/Applications/Amphetamine.app" # mas apps always install to /Applications
          "${appdir}/BetterTouchTool.app"
          "${appdir}/DarkModeBuddy.app"
          "${appdir}/Flux.app"
          "${appdir}/KDE Connect.app"
          "${appdir}/KeePassXC.app"
          "${appdir}/macOS InstantView.app"
          "${appdir}/Stretchly.app"
          "${appdir}/Syncthing.app"
        ];
        appEntries = map
          (app: { path = app; hidden = true; })
          apps;

        # This somehow seems to be the only way to add apps to "Open at Login" that doesn't
        # involve launchd, and there doesn't seem to be any `defaults` for it anymore
        updateEntries = /* javascript */ ''
          "use strict";
          (() => {
            const se = Application("System Events");

            // https://stackoverflow.com/a/48026729
            while (se.loginItems.length > 0) {
              se.loginItems[0].delete();
            }

            // This interface is strange... https://bru6.de/jxa/basics/working-with-objects/
            for (const app of ${builtins.toJSON appEntries}) {
              se.loginItems.push(se.LoginItem(app));
            }
          })()
        '';
      in
        /* bash */ ''
        /usr/bin/osascript -l JavaScript -e ${lib.escapeShellArg updateEntries}
      '';
  };

  #endregion

  #region nix-darwin internals

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  #endregion
}
