{ self, lib, pkgs, ... }:
let
  inherit (self.lib.dock) app-in-dir system-app small-spacer;
  app = app-in-dir "/Applications";
in
{
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
    "com.apple.dock" = {
      persistent-apps = [
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
        (app "Emacs")
        small-spacer
        (system-app "Calculator")
        (system-app "Utilities/Activity Monitor")
        (app "Spotify")
      ];
    };
  };
}
