/**
  This should be usable as a module for nix-darwin, nixos or home-manager,
  since they all use the same option for nixpkgs.overlays.

  If home-manager.useGlobalPkgs = true, this *must* be used as a nix-darwin/nixos
  module to have an effect, since home-manager's nixpkgs.overlays will be ignored.

  It's *not* named overlays.nix so that it isn't picked up automatically by nix
  commands.
*/
{ host, lib, ... }:
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

      nil = prev.nil.overrideAttrs
        (old: {
          version = "2024-11-19";
          src = prev.fetchFromGitHub {
            owner = "oxalica";
            repo = "nil";
            rev = "2e24c9834e3bb5aa2a3701d3713b43a6fb106362";
            hash = "sha256-DCIVdlb81Fct2uwzbtnawLBC/U03U2hqx8trqTJB7WA=";
          };
          # https://wiki.nixos.org/wiki/Overlays#Rust_packages
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (final.nil) src;
            name = "nil-cargo-vendor-deps";
            hash = "sha256-Q4wBZtX77v8CjivCtyw4PdRe4OZbW00iLgExusbHbqc=";
          };
        });

      # Some packages (mainly bash-based) get built as a wrapped "resholve" script, so we
      # actually want to patch the source of the unwrapped pre-resholve derivation (i.e.
      # the unresholved package's src attribute).
      nix-direnv = prev.nix-direnv.overrideAttrs
        (unresholved: {
          src = appendPatches unresholved.src [
            ./patches/nix-direnv/0001-Supress-stderr-for-nix-flake-archive.patch
          ];
        });

      yadm =
        let
          # Sheesh, patching this is kinda messy; upstream nixpkgs is only on 3.3.0
          version = "3.5.0";
          src = prev.fetchFromGitHub {
            owner = "yadm-dev";
            repo = "yadm";
            rev = "366c3ec418547af2837e5f486669a838cc99563c";
            hash = "sha256-5TUL4aQ/i+RNp5PtcoTSWJa8RSiB042zc8xoJSpWVMQ=";
          };
          # TODO: upstream this patch in a PR for 3.5.1 or 3.6.0
          patches = [
            (prev.fetchpatch {
              url = "https://github.com/yadm-dev/yadm/commit/3fa4b3cf60cc9befb2b3a5b740aca2674bc6ac35.patch";
              hash = "sha256-87XqVBu9OB6RsQaWfJJ2MCaEAGnxLtvslQ8NNt+J2N4=";
            })
          ];
          patchedYadm = prev.yadm.overrideAttrs (unresholved: {
            src = appendPatches
              (unresholved.src.overrideAttrs { inherit src version; })
              patches;
          });
          # 3.5.0 had some refactors which requires more resholve directives:
          mkResholve = args @ { solutions, ... }:
            prev.resholve.mkDerivation (args // {
              # Helpful post: https://t-ravis.com/post/nix/advanced_shell_packaging_resholve_yadm/
              solutions = lib.recursiveUpdate solutions {
                yadm.keep = {
                  "$processor" = true;
                  "$log" = true;
                };
              };
            });
        in
        patchedYadm.override {
          inherit (prev.python311Packages) j2cli;
          resholve = prev.resholve // { mkDerivation = mkResholve; };
        };


    })
  ];
}
