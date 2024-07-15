info: final: prev:
let
  nixpkgs =
    if prev ? legacyPackages then prev
    else builtins.getFlake "nixpkgs";
in
{
  pkgs = nixpkgs.legacyPackages.${info.currentSystem};
  inherit (final.pkgs) lib stdenv;
}
