{ self, config, pkgs, user, ... }: {
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

    # TODO: defaults might get big enough to deserve its own module
    defaults = {

      dock =
        let
          # How is there not a builtin or lib function for this???
          appdir =
            if config.homebrew.caskArgs.appdir == null then
              "/Applications"
            else
              config.homebrew.caskArgs.appdir;
        in
        {
          # TODO: these might vary by class, ~/Applications for some apps
          persistent-apps =
            [
              "/System/Applications/System Settings.app"
              "${appdir}/KeePassXC.app"
              "/${appdir}/Firefox.app"
              # TODO: can we stick a spacer in here somehow?

              "/${appdir}/Slack.app"
              "/${appdir}/Microsoft Teams.app"
              "/${appdir}/Visual Studio Code.app"
              "/${appdir}/iTerm.app/"

              "/${appdir}/Fork.app/"
              # "/${appdir}/Insomnium.app/" # Not installable atm
              "/${appdir}/Emacs.app" # requires a symlink, not a macOS alias as the brew caveat describes


              "/System/Applications/Calculator.app"
              "/System/Applications/Utilities/Activity Monitor.app"
              "/${appdir}/Spotify.app/"
            ];

          # TODO: file docs issue that "~" doesn't work here. Would also be nice
          # if it's possible to specify display options...
          persistent-others = let home = config.users.users.${user}.home; in [
            "${home}/Library/Application Support"
            home
            appdir
            "${home}/Documents"
            "${home}/Downloads"
          ];
        };
    };
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


