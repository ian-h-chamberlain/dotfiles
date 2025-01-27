{ host, lib, pkgs, ... }:
let
  wsl = host.wsl or false;
in
{
  imports = [
    ./scoop.nix
  ];

  wsl = lib.mkIf wsl {
    wslConf.user.default = host.user;
  };

  programs.nix-ld = lib.mkIf wsl {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
