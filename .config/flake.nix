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
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nix itself, i.e. Lix
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix.git?ref=main";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixos";
      inputs.lix.follows = "lix";
    };

    # Home-manager, OS-specific modules, etc.
    home-manager = {
      # Until I get around to upstreaming this patch for
      # https://github.com/nix-community/home-manager/issues/5602
      url = "github:ian-h-chamberlain/home-manager?ref=feature/fish-session-vars-pkg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixos";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nix-darwin
    , home-manager
    , nix-homebrew
    , ...
    }:
    let
      inherit (builtins) mapAttrs;
      inherit (nixpkgs) lib;

      # TODO: maybe use https://github.com/numtide/flake-utils to help abstract
      # the per-system logic stuff...
      hosts = {
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
      darwinSystems = lib.filterAttrs (_: { system, ... }: isDarwin system) hosts;

      isNixOS = host: host.nixos or false;
      nixosSystems = lib.filterAttrs (_: isNixOS) hosts;

      systemPkgsFor =
        host:
        inputs.nixpkgs.legacyPackages.${host.system};

      specialArgsFor =
        hostname:
        {
          inherit self;
          host = { name = hostname; wsl = false; } // hosts.${hostname};
        };
    in
    {
      lib = import ./nix/lib.nix (inputs // { inherit lib; });

      darwinConfigurations = mapAttrs
        (
          hostname:
          { system, user, ... }:
          nix-darwin.lib.darwinSystem {
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
          }
        )
        darwinSystems;

      nixosConfigurations = mapAttrs
        (
          hostname:
          { system
          , user
          , wsl ? false
          , ...
          }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit (inputs) lix-module;
            } // specialArgsFor hostname;

            modules = [
              # Disabled for now: https://git.lix.systems/lix-project/lix/issues/652
              # inputs.lix-module.nixosModules.default
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
              ./nixos/configuration.nix
              ./nixpkgs/flake-overlays.nix
            ];
          }
        )
        nixosSystems;

      homeConfigurations = lib.mapAttrs'
        (
          hostname:
          { system, user, ... }:
          lib.nameValuePair "${user}@${hostname}" (
            if isDarwin system then
            # Expose the home configuration built by darwinModules.home-manager:
              let
                homeCfg = self.darwinConfigurations.${hostname}.config.home-manager.users.${user};
              in
              {
                inherit (homeCfg.home) activationPackage;
                config = homeCfg;
              }
            else
              let pkgs = nixpkgs.legacyPackages.${system}; in
              home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = specialArgsFor hostname;
                modules = [
                  ./home-manager/home.nix
                  ./nixpkgs/flake-overlays.nix
                  # nixos and darwin get this from the host configuration
                  { nix.package = pkgs.lix; }
                ];
              }
          )
        )
        hosts;

      # Used for bootstrapping
      devShells = lib.mapAttrs'
        (
          _: host:
            let
              pkgs = systemPkgsFor host;
            in
            lib.nameValuePair host.system {
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
        hosts;

      formatter = lib.mapAttrs'
        (_: host: lib.nameValuePair host.system (systemPkgsFor host).nixfmt-rfc-style)
        hosts;
    };
}
