{ host, lib, pkgs, ... }: {
  imports = [
    ./wsl/scoop.nix
  ];

  wsl = lib.mkIf host.wsl {
    wslConf.user.default = host.user;
  };

  programs.nix-ld = lib.mkIf host.wsl {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
