{ host, lib, pkgs, ... }:
let
  isWsl = host.wsl or false;
in
{
  imports = [
    ./scoop.nix
  ];

  wsl = lib.mkIf isWsl {
    enable = true;
    defaultUser = host.user;
    wslConf = {
      user.default = host.user;
      network.hostname = host.name;
    };
  };

  programs.nix-ld = lib.mkIf isWsl {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # Enable mDNS for reaching windows via .local hostname
  services.avahi = lib.mkIf isWsl {
    enable = true;
    nssmdns4 = true;
  };


  security.pki.certificates = [ ];
}
