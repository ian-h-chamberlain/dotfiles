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

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nix-darwin = {
      url = "flake:nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      # Until I get around to upstreaming this patch for
      # https://github.com/nix-community/home-manager/issues/5602
      url = "github:ian-h-chamberlain/home-manager?ref=feature/fish-session-vars-pkg";
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
        Ian-PC = {
          system = "x86_64-linux";
          user = "ian";
          class = "personal";
          wsl = true;
          nixos = true;
        };
        Disney-PC = {
          system = "x86_64-linux";
          user = "ian";
          class = "work";
          wsl = true;
          nixos = true;
        };
      };

      isDarwin = system: lib.hasSuffix "darwin" system;
      darwinSystems = lib.filterAttrs (_: { system, ... }: isDarwin system) systems;

      nixosSystems = lib.filterAttrs (_: { nixos ? false, ... }: nixos) systems;

      systemPkgs = system:
        if isDarwin system then
          inputs.nixpkgs-darwin.legacyPackages.${system}
        else
          inputs.nixpkgs.legacyPackages.${system};

      specialArgsFor = hostname: {
        inherit self;
        host = systems.${hostname} // { name = hostname; };
        unstable = inputs.nixpkgs-unstable.legacyPackages.${systems.${hostname}.system};
      };
    in
    {
      lib = import ./nix/lib.nix (inputs // { inherit lib; });

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
            ./nixpkgs/flake-overlays.nix
          ];
        })
        darwinSystems;

      nixosConfigurations = mapAttrs
        (hostname: { system, user, wsl ? false, ... }: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgsFor hostname;

          modules = [
            ./nixos/configuration.nix
            inputs.nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./home-manager/home.nix;
                extraSpecialArgs = specialArgsFor hostname;
              };
            }
          ];
        })
        nixosSystems;

      homeConfigurations = lib.mapAttrs'
        (hostname: { system, user, ... }: lib.nameValuePair
          "${user}@${hostname}"
          (if isDarwin system then
          # Expose the home configuration built by darwinModules.home-manager:
            let homeCfg = self.darwinConfigurations.${hostname}.config.home-manager.users.${user};
            in {
              inherit (homeCfg.home) activationPackage;
              config = homeCfg;
            }
          else
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              extraSpecialArgs = specialArgsFor hostname;
              modules = [
                ./home-manager/home.nix
                {
                  # nixos and darwin get this from the host configuration
                  nix.package = inputs.unstable.lix;
                }
                ./nixpkgs/flake-overlays.nix
              ];
            }))
        systems;

      darwinOptions =
        let
          config = nix-darwin.lib.darwinSystem {
            pkgs = inputs.nixpkgs-darwin;
            system = "x86_64-darwin";
            modules = [
              # nix-homebrew.darwinModules.nix-homebrew
              # home-manager.darwinModules.home-manager
            ];
          };
        in
        config.options;

      homeOptions =
        let
          config = home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-darwin.legacyPackages.aarch64-darwin;
            modules = [{
              home.username = "dummy";
              home.homeDirectory = /home/dummy;
              home.stateVersion = "20.09"; # TODO reference self
            }];
          };
        in
        config.options;

      # Used for bootstrapping
      devShells = lib.mapAttrs'
        (_: { system, ... }:
          let pkgs = systemPkgs system;
          in lib.nameValuePair
            system
            {
              default = pkgs.mkShell {
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
