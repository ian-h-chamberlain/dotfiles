{ pkgs, lib, ... }:
let
  pinentry-injector = pkgs.callPackage ./pinentry-injector/package.nix { };

  # Request pinentry via Git-bash's GPG instead of pinentry-curses
  pinentry-wrapper = pkgs.writeShellApplication {
    name = "pinentry-win";
    # TODO: PR these as inputs for nixpkgs#wslu itself?
    runtimeInputs = with pkgs; [
      wslu
      coreutils
      gnused
      pinentry-injector
    ];
    # TODO: if I write a real program to intercept stdin/stdout I can inject
    # a SETTITLE command using the key name for AutoType to work nicer. Ideally
    # cross-platform enough to work on native windows too
    text = # bash
      ''
        # Add wslpath to PATH (for wslu to work properly)
        export PATH=/bin:$PATH
        # Gpg4Win's pinentry-qt seems better behaved than plain pinentry from Git for Windows
        real_pinentry="$(wslpath "$(wslvar -s USERPROFILE)")/scoop/apps/gpg4win/current/Gpg4win/bin/pinentry.exe"
        exec "${lib.getExe pinentry-injector}" "$real_pinentry" "$@"
      '';
  };
in
{
  services.gpg-agent.pinentryPackage = pinentry-wrapper;

  home.file.".local/bin/xdg-open".source = lib.getExe' pkgs.wslu "wslview";
  home.packages = with pkgs; [
    wslu
    pinentry-wrapper
  ];
}
