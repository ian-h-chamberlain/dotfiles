{ pkgs, ... }:
let
  name = "pinentry-injector";
  version = "0.1.0";
in
pkgs.buildGoModule {
  pname = name;
  inherit version;

  meta.mainProgram = "pinentry-injector";

  # Since it's just a single-file zero-dependency app, generate go.mod on the fly
  # and pretend its dependencies are vendored.
  src = ./.;
  patchPhase = ''
    go mod init ian-h-chamberlain.com/pinentry-injector
  '';
  vendorHash = null;
}
