{
  host,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports =
    [ ./scoop.nix ]
    ++ self.lib.existingPaths [
      ./${host.class}.nix
    ];

  config = lib.mkIf (host.wsl or false) {
    wsl = {
      enable = true;
      defaultUser = host.user;
      wslConf = {
        user.default = host.user;
        network.hostname = host.name;
        interop.appendWindowsPath = false;
      };
    };

    programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };

    users.groups.podman = {
      gid = 10;
      members = [ host.user ];
    };

    # there might be a nicer way to do this tbh with mkOutOfStoreSymlink or something
    # Or, my own module option which just nicely concatenates dirs like upstream
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/fonts/fontconfig.nix#L55
    fonts.fontconfig.localConf = # xml
      ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
        <fontconfig>
          <!-- Font directories. NOTE: these are *really* slow to load with Windows/WSL2 interop  -->
          <dir>/mnt/c/Windows/Fonts</dir>
          <dir>/mnt/c/Users/CHAMI008/AppData/Local/Microsoft/Windows/Fonts</dir>
        </fontconfig>
      '';

    nixpkgs.overlays = [
      (final: prev: {
        fish = prev.fish.overrideAttrs (old: {
          # Force WSL detection to avoid autocompleting .dll files, it seems to be broken in 3.x, possibly fixed in 4.0.
          # https://github.com/fish-shell/fish-shell/blob/3.7.1/src/common.cpp#L133
          #
          # This does have the side effect of using ¶ instead of ⏎ for newlines (and maybe also other side effects)...
          # https://github.com/fish-shell/fish-shell/commit/412c5aeaa63caa3534a0b966e3ad510969904dc6
          cmakeFlags = old.cmakeFlags ++ [ "-DWSL=ON" ];
        });
      })
    ];

    # Enable mDNS for reaching windows via .local hostname
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };

    security.pki.certificates = [ ];
  };
}
