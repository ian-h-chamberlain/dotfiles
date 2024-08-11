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
      systems = {
        MacBook-Pro = {
          system = "aarch64-darwin";
          user = "ianchamberlain";
          class = "personal";
        };
        # NOTE: this is actually my older laptop despite the name
        ichamberlain-mbp-2 = {
          system = "x86_64-darwin";
          user = "ichamberlain";
          class = "work";
        };
        ichamberlain-mbp-M3 = {
          system = "aarch64-darwin";
          user = "ichamberlain";
          class = "work";
        };
        # TODO: switch prismo over to flakes
        prismo = {
          system = "x86_64-linux";
          user = "ianchamberlain";
          class = "personal";
        };
        dev-ichamberlain = rec {
          system = "x86_64-linux";
          user = "ichamberlain";
          class = "work";
          # Unusual case:
          homeDirectory = "/Users/${user}";
        };
      };

      isDarwin = system: lib.hasSuffix "darwin" system;
      darwinSystems = lib.filterAttrs (_: { system, ... }: isDarwin system) systems;

      specialArgsFor = hostname: {
        inherit self;
        host = systems.${hostname} // { name = hostname; };
        unstable = inputs.nixpkgs-unstable.legacyPackages.${systems.${hostname}.system};
      };
    in
    {
      # Helper functions that aren't in upstream nixpkgs.lib. It would be nice
      # for this to be usable as a module that extends nixpkgs.lib for the
      # appropriate `pkgs`, but for now `self.lib` is good enough
      lib = {
        /**  Return the given value if non-null, otherwise the given `default` */
        unwrapOr = default: v:
          if v == null then default else v;

        /** Filter a list of paths to include only those that actually exist */
        existingPaths = builtins.filter builtins.pathExists;

        /** Enable "escape sequences" in a string by (ab)using the builtin Nix JSON parser.
          For readability / sanity, this should probably only ever be used with a
          single-quoted '' literals for backslashes to work as expected.
          <https://github.com/NixOS/nix/issues/10082>
        */
        unescape = s:
          let escaped = builtins.replaceStrings [ "\"" ] [ "\\\"" ] s;
          in builtins.fromJSON ''"${escaped}"'';

        /** com.apple.dock helpers */
        dock = with self.lib.dock; {
          path-entry = path: {
            tile-data = {
              file-data = {
                _CFURLString = "${path}";
                _CFURLStringType = 0;
              };
            };
          };

          folder = path: lib.recursiveUpdate (path-entry path) {
            tile-data = {
              # Show as folder icon instead of stack etc.
              displayas = 1;
              # Use default appearance for contents, set 2 to force grid here
              showas = 0;
            };
            tile-type = "directory-tile";
          };

          app-in-dir = dir: appName: path-entry "${dir}/${appName}.app";
          system-app = app-in-dir "/System/Applications";
          small-spacer = {
            tile-data = { };
            tile-type = "small-spacer-tile";
          };
        };
      };

      darwinConfigurations = mapAttrs
        (hostname: { system, user, ... }: nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = specialArgsFor hostname;

          modules = [
            ./nix-darwin/configuration.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                inherit user;
                # TODO: Declarative tap management
              };
            }
            home-manager.darwinModules.home-manager
            {
              # home-manager module expects this to be set:
              users.users.${user}.home = "/Users/${user}";
              home-manager = {
                useGlobalPkgs = true;
                users.${user} = import ./home-manager/home.nix;
                extraSpecialArgs = specialArgsFor hostname;
              };
            }
          ];
        })
        darwinSystems;

      # Exposed for convenience
      darwinPackages = mapAttrs (cfg: cfg.pkgs) self.darwinConfigurations;

      homeConfigurations = lib.mapAttrs'
        (hostname: { system, user, ... }: lib.nameValuePair
          "${user}@${hostname}"
          (if isDarwin system then
          # Expose the home configuration built by darwinModules.home-manager:
            self.darwinConfigurations.${hostname}.config.home-manager.users.${user}
          else
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              specialArgs = specialArgsFor hostname;
              modules = [
                ./home-manager/home.nix
                ({ pkgs, ... }: {
                  nix.package = pkgs.lix;
                })
              ];
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
            {
              default = pkgs.mkShell {
                # Minimal set of packages needed for bootstrapping dotfiles
                packages = with pkgs; [
                  cacert
                  git
                  git-crypt
                  git-lfs
                  gnupg
                  yadm
                ];
              };
            }
        )
        systems;
    };
}
