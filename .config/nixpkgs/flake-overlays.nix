/**
  This should be usable as a module for nix-darwin, nixos or home-manager,
  since they all use the same option for nixpkgs.overlays.

  If home-manager.useGlobalPkgs = true, this *must* be used as a nix-darwin/nixos
  module to have an effect, since home-manager's nixpkgs.overlays will be ignored.

  It's *not* named overlays.nix so that it isn't picked up automatically by nix
  commands.
 */
{ ... }:
let
  appendPatches = pkg: patches:
    pkg.overrideAttrs (old: { patches = (old.patches or [ ]) ++ patches; });
in
{
  nixpkgs.overlays = [
    (final: prev:
      {
        htop = appendPatches prev.htop [
          ./patches/htop/0001-Re-title-the-main-menu-bar-for-its-shortcuts.patch
        ];

        # Yadm gets built as a wrapped "resholve" script, so we actually
        # want to patch the source of the unwrapped pre-resholve derivation:
        yadm = prev.yadm.overrideAttrs (unresholved: {
          src = appendPatches unresholved.src [
            (prev.fetchpatch {
              url = "https://github.com/TheLocehiliosan/yadm/pull/495.patch";
              hash = "sha256-xIXqXo8pQywufvcfY+j3jne5WdYnS9/t5DQdpXAkZbo=";
              excludes = [ "test/*" ];
            })
          ];
        });
      })
  ];
}
