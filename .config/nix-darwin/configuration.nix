{ self, lib, config, pkgs, user, ... }: {
  imports = [
    ./homebrew.nix
  ];

  # Basic packages that are needed by nearly everything
  environment.systemPackages = with pkgs; [
    curl
    cacert
  ];

  # https://github.com/LnL7/nix-darwin/issues/239#issuecomment-719873331
  programs.fish.enable = true;

  # Doesn't seem to work: https://github.com/LnL7/nix-darwin/issues/811
  users.users.${user}.shell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
  environment.loginShell = "${pkgs.fish}/bin/fish";

  # Symlink to dotfiles flake for easier activation
  # See https://github.com/LnL7/nix-darwin/pull/741
  environment.etc."nix-darwin/flake.nix".source =
    "${config.users.users.${user}.home}/.config/flake.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.lix;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  #region macOS settings

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Set up apps after homebrew, so that everything we try to add should be installed
    activationScripts.postUserActivation.text =
      let
        appdir = self.lib.unwrapOr "/Applications" config.homebrew.caskArgs.appdir;
        apps = [
          "/Applications/Amphetamine.app" # mas apps always install to /Applications
          "${appdir}/BetterTouchTool.app"
          "${appdir}/DarkModeBuddy.app"
          "${appdir}/Flux.app"
          "${appdir}/KDE Connect.app"
          "${appdir}/KeePassXC.app"
          "${appdir}/macOS InstantView.app"
          "${appdir}/Proxy Audio Device Settings.app"
          "${appdir}/Stretchly.app"
          "${appdir}/Syncthing.app"
        ];
        appEntries = map
          (app: { path = app; hidden = true; })
          apps;
      in
      # This somehow seems to be the only way to add apps to "Open at Login" that doesn't
        # involve launchd, and there doesn't seem to be any `defaults` for it anymore
      ''
        /usr/bin/osascript -l JavaScript -e '
          "use strict";
          (() => {
            const se = Application("System Events");

            // https://stackoverflow.com/a/48026729
            while (se.loginItems.length) {
              se.loginItems[0].delete();
            }

            // This interface is strange... https://bru6.de/jxa/basics/working-with-objects/
            for (const app of ${builtins.toJSON appEntries}) {
              se.loginItems.push(se.LoginItem(app));
            }
          })()
        '
      '';
  };

  #endregion

  # TODO idea: a module that installs
  # https://github.com/Lord-Kamina/SwiftDefaultApps (possible via homebrew)
  # and allows for declaration of default app handlers

  #region nix-darwin

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  #endregion
}
