# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ian-nixos"; # Define your hostname.

  # Use NetworkManager for all network configuration.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    firefox
    docker
  ];

  # TODO: ensure home-manager installed as a system package

  # Allow unfree software (required for some drivers)
  nixpkgs.config.allowUnfree = true;

  # Enable gpg-agent in user sessions
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8200  # Deluge web interface

    # Plex media server
    32400
    3005
    8324
    32469
  ];
  networking.firewall.allowedUDPPorts = [
    # UPnP
    1900

    # Plex media server
    32410
    32412
    32413
    32414
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # TODO: use podman from unstaable instead of docker
  virtualisation.docker = {
    enable = true;
  };

  # Groups for use with media server
  users.groups = {
    ums.gid = 500;
    deluge.gid = 501;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ianchamberlain = {
    isNormalUser = true;
    extraGroups = [
      "wheel"           # Enable ‘sudo’ for the user.
      "networkmanager"  # Allow managing network settings
      # Stuff for media server
      "docker"
      "ums"
      "deluge"
    ]; 
    shell = unstable.fish;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

