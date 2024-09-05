/**
  This should be usable as a module for nix-darwin, nixos or home-manager,
  since they all use the same option for nixpkgs.overlays.

  If home-manager.useGlobalPkgs = true, this *must* be used as a nix-darwin/nixos
  module to have an effect, since home-manager's nixpkgs.overlays will be ignored.
 */
{ ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      htop = prev.htop.overrideAttrs
        (old: {
          patches = (old.patches or [ ]) ++ [
            ./patches/htop/0001-Re-title-the-main-menu-bar-for-its-shortcuts.patch
          ];
        });
    })
  ];
}
