/**
  This should be usable as a module for nix-darwin, nixos or home-manager,
  since they all use the same option for nixpkgs.overlays.

  If home-manager.useGlobalPkgs = true, this *must* be used as a nix-darwin/nixos
  module to have an effect, since home-manager's nixpkgs.overlays will be ignored.

  It's *not* named overlays.nix so that it isn't picked up automatically by nix
  commands.
*/
{
  lib,
  unstable,
  pkgs,
  ...
}:
let
  appendPatches =
    pkg: patches:
    pkg.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ patches;
    });
in
{
  nixpkgs.overlays = [
    (final: prev: {
      htop = appendPatches prev.htop [
        ./patches/htop/0001-Re-title-the-main-menu-bar-for-its-shortcuts.patch
      ];

      # Pulling from unsable is probably not _really_ how overlays are meant to be used
      # and I should be calling unstable.extend or something, but meh it's fine for now
      nil = unstable.nil.overrideAttrs (
        prev:
        let
          src = pkgs.fetchFromGitHub {
            owner = "oxalica";
            repo = "nil";
            rev = "2e24c9834e3bb5aa2a3701d3713b43a6fb106362";
            hash = "sha256-DCIVdlb81Fct2uwzbtnawLBC/U03U2hqx8trqTJB7WA=";
          };
        in
        {
          version = "2024-11-19";
          inherit src;

          # https://wiki.nixos.org/wiki/Overlays#Rust_packages
          cargoDeps = prev.cargoDeps.overrideAttrs (_: {
            name = "oxalica-nil-vendor.tar.gz";
            inherit src;
            outputHash = "sha256-qW6xqYVQbvZUL5mJAzh8T6udUYIpk8nKoOihoD1UmXA=";
          });
        }
      );

      # Some packages (mainly bash-based) get built as a wrapped "resholve" script, so we
      # actually want to patch the source of the unwrapped pre-resholve derivation (i.e.
      # the src attribute on the final derivation).

      yadm = prev.yadm.overrideAttrs (unresholved: {
        src = appendPatches unresholved.src [
          (prev.fetchpatch {
            url = "https://github.com/TheLocehiliosan/yadm/pull/495.patch";
            hash = "sha256-xIXqXo8pQywufvcfY+j3jne5WdYnS9/t5DQdpXAkZbo=";
            excludes = [ "test/*" ];
          })
        ];
      });

      nix-direnv = unstable.nix-direnv.overrideAttrs (unresholved: {
        src = appendPatches unresholved.src [
          ./patches/nix-direnv/0001-Supress-stderr-for-nix-flake-archive.patch
        ];
      });
    })
  ];
}
