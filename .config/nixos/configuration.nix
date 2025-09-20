{ config, lib, self, pkgs, host, ... }:
{
  # TODO: when converting prismo, will probably import ./prismo.nix or something
  imports = [
    ./wsl
  ] ++ self.lib.existingPaths [
    ./${host.name}
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Disable the global flake registry; nixpkgs came free with your cfg!
      # This might make more sense in home.nix to work on darwin etc too
      flake-registry = null;
      use-xdg-base-directories = true;
    };
    extraOptions = ''
      !include /etc/nix/secrets.conf
    '';
    package = pkgs.lix;
  };

  # Allow unfree software (required for some drivers)
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  documentation.dev.enable = true;
  environment = {
    systemPackages = with pkgs; [
      git
      python3
      nixos-option
      vim
      wget
    ];

    # Probably overkill but let's just try
    enableAllTerminfo = true;

    etc =
      let
        homeDir = config.users.users.${host.user}.home;
      in
      {
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

  services.openssh.enable = true;

  # Based on /bin/sh:
  # https://github.com/NixOS/nixpkgs/blob/8261f6e94510101738ab45f0b877f2993c7fb069/nixos/modules/config/shells-environment.nix#L213
  system.activationScripts.binbash =
    let
      bash = lib.getExe config.system.build.binsh;
    in
    lib.stringAfter [ "stdio" ]
      # bash
      ''
        mkdir -m 0755 -p /bin
        ln -sfn "${bash}" /bin/.bash.tmp
        mv /bin/.bash.tmp /bin/bash # atomically replace /bin/bash
      '';

  systemd.coredump = {
    enable = true;
    # Explicit defaults:
    extraConfig = ''
      Storage=external
      Compress=yes
      # On 32-bit, the default is 1G instead of 32G.
      ProcessSizeMax=32G
      ExternalSizeMax=32G
      JournalSizeMax=767M
      MaxUse=
      KeepFree=
      EnterNamespace=no
    '';
  };

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
    };
    nix-ld.enable = true;
  };

  # Very slow with fish shell
  documentation.man.generateCaches = false;

  security.sudo.enable = true;

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
