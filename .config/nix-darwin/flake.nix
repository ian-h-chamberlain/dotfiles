{
  description = "Darwin flake configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      # https://github.com/LnL7/nix-darwin/pull/741
      url = "github:Enzime/nix-darwin/default-flake-location";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-config = {
      # This seems to be the only way to properly deal with the dotfiles
      # checkout being in a different place for different usernames:
      # https://discourse.nixos.org/t/flake-input-from-local-git-repo/27609/3
      # In theory I could probably even add the registry as part of nix-darwin activation,
      # although it's kinda chicken + egg. Maybe just part of yadm bootstrap?
      #
      # Also TBD: does it require things to be checked in? At least it's still local,
      # so I guess it would just require committing home-manager config before evaluation,
      # which is a pain but better than having to push to github first.
      url = "flake:home-manager-configuration";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.unstable.follows = "unstable";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager-config, ... } @ inputs:
  let
    hosts = {
      MacBook-Pro = {
        system = "aarch64-darwin";
        user = "ianchamberlain";
      };
      ichamberlain-mbp-2 = {
        system = "x86_64-darwin";
        user = "ichamberlain";
      };
    };
    inherit (nixpkgs) lib;
    inherit (nix-darwin.lib) darwinSystem;
  in {
    darwinConfigurations = lib.mapAttrs (hostname: host: darwinSystem {
      inherit (host) system;

      modules = [
        ./configuration.nix
        home-manager-config.inputs.home-manager.darwinModules.home-manager
        home-manager-config.homeConfigurations.${host.user}
      ];
      specialArgs = { inherit self host; };
    }) hosts;

    # Expose the package set, including overlays, for convenience.
    darwinPackages = lib.mapAttrs (hostname: _: self.darwinConfigurations.${hostname}.pkgs) hosts;
  };
}
