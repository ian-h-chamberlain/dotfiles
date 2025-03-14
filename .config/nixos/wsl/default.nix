{
  host,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./scoop.nix
  ];

  config = lib.mkIf (host.wsl or false) {
    wsl = {
      enable = true;
      defaultUser = host.user;
      wslConf = {
        user.default = host.user;
        network.hostname = host.name;
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
