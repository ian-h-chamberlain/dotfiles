{ self, lib, pkgs, osConfig, ... }:
let
  inherit (self.lib.dock) app-in-dir system-app small-spacer;
  app = app-in-dir osConfig.homebrew.caskArgs.appdir;
in
{
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
    "com.apple.dock" = {
      persistent-apps = [
        (system-app "System Settings")
        (app "KeePassXC")
        (app "Firefox")
        small-spacer

        (app "Visual Studio Code")
        (app "iTerm")
        (app "Fork")
        small-spacer

        (app "Emacs")
        (system-app "Utilities/Activity Monitor")
        (system-app "Calculator")
        small-spacer

        (app "Calibre")
        (app "Steam")
        (app "Discord")
        (app "Spotify")
      ];
    };
  };
}
