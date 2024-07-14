{
  description = ''
    Top-level dotfiles flake configuration. This flake is intended to have outputs for each of:
      - home-manager config on Linux (non-NixOS)
      - nix-darwin config
      - (eventually) NixOS configuration.

    NOTE: .config/.git must exist as a symlink to .local/share/yadm/repo.git
    or Nix may complain about "has an unsupported type" for untracked files
    under .config. This way, only yadm-tracked files are part of the
    context used by the flake: https://wiki.nixos.org/wiki/Flakes#Git_WARNING
  '';

  inputs = {
    # Gah there's so many of these!!!
    nixpkgs.url = "flake:nixpkgs/nixos-24.05";
    nixos-unstable.url = "flake:nixpkgs/nixos-unstable";

    nixpkgs-darwin.url = "flake:nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "flake:nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "flake:nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      # use stable version here to be compatible with stable darwin/nixos modules
      url = "flake:home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      inherit (builtins) mapAttrs;
      inherit (nixpkgs) lib;

      systems = {
        MacBook-Pro = {
          system = "aarch64-darwin";
          user = "ianchamberlain";
        };
        ichamberlain-mbp-2 = {
          system = "x86_64-darwin";
          user = "ichamberlain";
        };
        prismo = {
          system = "x86_64-linux";
          user = "ianchamberlain";
          # TODO: maybe some kinda nixos flag or something
        };
        # ??
        ichamberlain-dev = {
          system = "x86_64-linux";
          user = "ichamberlain";
        };
      };

      darwinSystems = lib.filterAttrs
        (_: { system, ... }: lib.hasSuffix "darwin" system)
        systems;

      # TODO: actually use this and switch prismo over to flakes
      nixosSystems = { inherit (systems) prismo; };
    in
    {
      darwinConfigurations = mapAttrs
        (hostname: { system, user }: nix-darwin.lib.darwinSystem {
          inherit system;

          modules = [
            ./nix-darwin/configuration.nix
            {
              # home-manager module expects this to be set:
              users.users.${user}.home = "/Users/${user}";
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                users.${user} = import ./home-manager/home.nix;
                extraSpecialArgs = {
                  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
                };
                verbose = true;
              };
            }
          ];

          specialArgs = { inherit self user; };
        })
        darwinSystems;

      darwinPackages = mapAttrs (host: _: self.darwinConfigurations.${host}.pkgs) darwinSystems;

      homeConfigurations = mapAttrs
        (host: { system, user }: home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home-manager/home.nix
            {
              home.username = "${user}";
              # TODO This is different on most Linuxes:
              home.homeDirectory = "/Users/${user}";
            }
          ];

          extraSpecialArgs = {
            username = user;
            pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
          };
        })
        systems;

      homePackages = mapAttrs (host: { user, ... }: self.homeConfigurations."${user}".pkgs) systems;
    };
}
