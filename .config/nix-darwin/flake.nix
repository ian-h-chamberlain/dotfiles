{
  description = "Default darwin flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      # https://github.com/LnL7/nix-darwin/pull/741
      url = "github:Enzime/nix-darwin/default-flake-location";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs } @ inputs:
  let
    hosts = [
      "MacBook-Pro"
    ];
    # This feels... inelegant, there must be some better way to do it
    forEachHost = result: builtins.listToAttrs (map (host: {
      name = host;
      value = result host;
    }) hosts);
  in {
    darwinConfigurations = forEachHost (host: nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix ];
      specialArgs = { inherit self host; };
    });

    # Expose the package set, including overlays, for convenience.
    darwinPackages = forEachHost (host: self.darwinConfigurations."${host}".pkgs);
  };
}
