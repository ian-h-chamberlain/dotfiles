{ self, config, pkgs, user, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # https://github.com/LnL7/nix-darwin/issues/239#issuecomment-719873331
  programs.fish.enable = true;

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

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
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
