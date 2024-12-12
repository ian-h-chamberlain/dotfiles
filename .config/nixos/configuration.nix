{ config, lib, pkgs, unstable, host, ... }:
{
  # TODO: when converting prismo, will probably import ./prismo.nix or something
  imports = [
    ./wsl
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = unstable.lix;

  time.timeZone = "America/New_York";

  environment = {
    systemPackages = with pkgs; [
      git
      python3
      vim
      wget
    ];

    etc = let homeDir = config.users.users.${host.user}.home; in {
      # Symlink to dotfiles flake for easier activation
      "nixos/flake.nix".source = "${homeDir}/.config/flake.nix";
    };

    # Override the default aliases, I brought my own
    shellAliases = {
      ls = null;
      ll = null;
      l = null;
    };
  };


  # Based on /bin/sh:
  # https://github.com/NixOS/nixpkgs/blob/8261f6e94510101738ab45f0b877f2993c7fb069/nixos/modules/config/shells-environment.nix#L213
  system.activationScripts.binbash =
    let bash = lib.getExe config.system.build.binsh; in
    lib.stringAfter [ "stdio" ]
      /*bash*/ ''
      mkdir -m 0755 -p /bin
      ln -sfn "${bash}" /bin/.bash.tmp
      mv /bin/.bash.tmp /bin/bash # atomically replace /bin/bash
    '';


  programs = {
    fish.enable = true;
  };

  users.users.${host.user} = {
    isNormalUser = true;
    extraGroups = [
      # Enable sudo
      "wheel"
    ];
    shell = pkgs.fish;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
