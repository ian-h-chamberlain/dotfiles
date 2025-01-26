{ currentSystem, ... }: final: prev:
let
  nixpkgs =
    if prev ? legacyPackages then prev
    else builtins.getFlake "nixpkgs";
in
{
  pkgs = nixpkgs.legacyPackages.${currentSystem};
  inherit (final.pkgs) lib stdenv;
  inherit (builtins) head tail;
}
