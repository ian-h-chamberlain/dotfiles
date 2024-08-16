{ self, lib, pkgs, ... }:
let
  /** Mini-DSL for defining keyboard shortcuts. */
  keyboardShortcuts = shortcutKeys:
    let
      esc = self.lib.unescape ''\u001B'';
      /** Convert the System Settings format to its backing plist format. */
      menuAction = action:
        let actions = lib.splitString "->" action; in
        if builtins.length actions == 1 then action
        else esc + (builtins.concatStringsSep esc actions);
    in
    {
      NSUserKeyEquivalents = lib.mapAttrs'
        (action: keys: lib.nameValuePair (menuAction action) keys)
        shortcutKeys;
    };

  keys = {
    shift = "$";
    ctrl = "^";
    cmd = "@";
    alt = "~";
    # notably, not the same as the \x1B used as action separator:
    esc = "⎋";
  };
in
{
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin (
    lib.mapAttrs
      (k: keyboardShortcuts)
      (with keys; {
        "com.apple.finder" = {
          "New iTerm2 Window Here" = cmd + shift + "x";
        };

        "com.DanPristupov.Fork" = {
          "File->Open..." = cmd + alt + "o";
          "Hide Untracked Files" = ctrl + "h";
          "Open in Terminal" = cmd + shift + "x";
          "Open" = cmd + "o";
        };
      })
  );
}
