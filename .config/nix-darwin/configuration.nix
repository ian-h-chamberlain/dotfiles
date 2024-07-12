{ self, host, pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.lix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  /* TODO: use home-manager for this stuff instead
  programs = {
    fish.enable = true;
    man.enable = true;
  };
  #*/

  security.pam.enableSudoTouchIdAuth = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # TODO idea: a module that installs
  # https://github.com/Lord-Kamina/SwiftDefaultApps (possible via homebrew)
  # and allows for declaration of default app handlers

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
