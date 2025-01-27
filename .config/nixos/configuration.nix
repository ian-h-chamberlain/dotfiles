{ config, lib, self, pkgs, host, ... }:
{
  # TODO: when converting prismo, will probably import ./prismo.nix or something
  imports = [
    ./wsl
  ] ++ self.lib.existingPaths [
    ./${host.name}
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.lix;

  # Allow unfree software (required for some drivers)
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      git
      python3
      nixos-option
      vim
      wget
    ];

    etc = let homeDir = config.users.users.${host.user}.home; in {
      # Symlink to dotfiles flake for easier activation
      "nixos/flake.nix".source = "${homeDir}/.config/flake.nix";
    };
  };

  programs.fish.enable = true;

  security.sudo.enable = true;

  time.timeZone = "America/New_York";

  users.users.${host.user} = {
    isNormalUser = true;
    extraGroups = [
      # Enable sudo
      "wheel"
    ];
    shell = pkgs.fish;
  };

  networking.hostName = host.name;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = host.stateVersion or "24.05"; # Did you read the comment?
}
