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
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      inputs.nix-darwin.follows = "nix-darwin";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      inherit (builtins) mapAttrs;
      inherit (nixpkgs) lib;

      # TODO: maybe use https://github.com/numtide/flake-utils to help abstract
      # the per-system logic stuff...
      # Should I define `yadm.class` type things here too?
      systems = {
        MacBook-Pro = {
          system = "aarch64-darwin";
          user = "ianchamberlain";
        };
        # NOTE: this is actually my older laptop despite the name
        ichamberlain-mbp-2 = {
          system = "x86_64-darwin";
          user = "ichamberlain";
        };
        ichamberlain-mbp-M3 = {
          system = "aarch64-darwin";
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
      # Helper functions that aren't in upstream nixpkgs.lib. It would be nice
      # for this to be usable as a module that extends nixpkgs.lib for the
      # appropriate `pkgs`, but for now `self.lib` is good enough
      lib = {
        # Return the given value if non-null, otherwise the given `default`
        unwrapOr =
          default:
          v: if v == null then default else v;
      };

      darwinConfigurations = mapAttrs
        (hostname: { system, user }: nix-darwin.lib.darwinSystem {
          inherit system;

          modules = [
            ./nix-darwin/configuration.nix
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                inherit user;
                # TODO: Declarative tap management
              };

              # home-manager module expects this to be set:
              users.users.${user}.home = "/Users/${user}";

              home-manager = {
                useGlobalPkgs = true;

                users.${user} = import ./home-manager/home.nix;

                extraSpecialArgs = {
                  inherit self;
                  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
                  nix-homebrew = inputs.nix-homebrew;
                };
              };
            }
          ];

          specialArgs = { inherit self user system; };
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
                inherit self;
                unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              };
            }))
        systems;

      devShells = lib.mapAttrs'
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
