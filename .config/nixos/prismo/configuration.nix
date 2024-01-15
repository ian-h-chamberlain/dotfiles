# To apply this file, symlink this directory to /etc/nixos
# E.g. `rm -rf /etc/nixos && ln -s $PWD /etc/nixos`

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # To use home-manager config in this file
      <home-manager/nixos>
    ];


  # ==========================================================================
  # Boot configuration
  # ==========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  # ==========================================================================
  # Networking configuration
  # ==========================================================================
  networking.hostName = "prismo";
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8200  # Deluge web interface

    # Plex media server
    32400
    3005
    8324
    32469

    # SMB share
    139
    445
  ];
  networking.firewall.allowedUDPPorts = [
    # UPnP
    1900

    # SMB share
    137
    138

    # Plex media server
    32410
    32412
    32413
    32414
  ];


  # ==========================================================================
  # Service configuration
  # ==========================================================================
  services.cron.enable = true;
  services.openssh.enable = true;

  # Prevent lid sleep when plugged in
  services.logind.lidSwitchExternalPower = "ignore";

  /* Uncomment these to enable graphical desktop
  # TODO can this just be a one-line import or something?

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  */


  # ==========================================================================
  # General system configuration
  # ==========================================================================
  time.timeZone = "America/New_York";

  # Allow unfree software (required for some drivers)
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    docker
    git
    hfsprogs
    firefox
    lm_sensors
    vim
    wget
  ];

  # TODO: use podman from unstaable instead of docker
  virtualisation.docker = {
    enable = true;
  };

  programs.fish.enable = true;

  # ==========================================================================
  # User configuration
  # ==========================================================================
  users.users.ianchamberlain = {
    isNormalUser = true;
    extraGroups = [
      # Enable sudo
      "wheel"

      # Allow managing network settings
      "networkmanager"

      # Groups for media server
      "docker"
      "deluge"
    ];
    shell = pkgs.fish;
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

