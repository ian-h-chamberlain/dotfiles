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

      # TODO: maybe use https://github.com/numtide/flake-utils to help abstract
      # the per-system logic stuff...
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
        # Unusual case:
        dev-ichamberlain = rec {
          system = "x86_64-linux";
          user = "ichamberlain";
          homeDirectory = "/Users/${user}";
        };
      };

      isDarwin = system: lib.hasSuffix "darwin" system;

      darwinSystems = lib.filterAttrs (_: { system, ... }: isDarwin system) systems;
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
              };
            }
          ];

          specialArgs = { inherit self user; };
        })
        darwinSystems;

      # Exposed for convenience
      darwinPackages = mapAttrs (cfg: cfg.pkgs) self.darwinConfigurations;

      homeConfigurations = lib.mapAttrs'
        (host: hostVars @ { system, user, ... }: lib.nameValuePair
          "${user}@${host}"
          (if isDarwin system then
          # Expose the home configuration built by darwinModules.home-manager:
            self.darwinConfigurations.${host}.config.home-manager.users.${user}
          else
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};

              modules = [
                ./home-manager/home.nix
                ({ pkgs, ... }: {
                  nix.package = pkgs.lix;
                })
              ];

              extraSpecialArgs = hostVars // {
                unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              };
            }))
        systems;

      devShell = lib.mapAttrs'
        (_: { system, ... }:
          let
            pkgs =
              if isDarwin system then
                inputs.nixpkgs-darwin.legacyPackages.${system}
              else
                inputs.nixpkgs.legacyPackages.${system};
          in
          lib.nameValuePair
            system
            (pkgs.mkShell {
              # Minimal set of packages needed for bootstrapping dotfiles
              packages = with pkgs; [
                cacert
                git
                git-crypt
                git-lfs
                gnupg
                yadm
              ];
            })
        )
        systems;
    };
}
