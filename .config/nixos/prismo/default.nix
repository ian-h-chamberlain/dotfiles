{ config, lib, host, pkgs, ... }:
let
  applesmc-next = with config.boot.kernelPackages;
    callPackage ./applesmc-next.nix { };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # ==========================================================================
  # Boot / kernel configuration
  # ==========================================================================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 0;
      "net.ipv6.conf.default.disable_ipv6" = 0;
      "net.ipv6.conf.lo.disable_ipv6" = 0;
    };

    extraModulePackages = [
      # Set custom kernel modules to be higher priority, so they override
      # default kernel module files (which seem to have priority 0)
      (lib.meta.hiPrio applesmc-next)
    ];

    # I think these might autoload anyway but let's load explicitly just in case
    kernelModules = [ "applesmc" "sbs" ];
  };

  # ==========================================================================
  # Networking configuration
  # ==========================================================================

  # TODO: might need to try using wpa_supplicant directly instead of nmcli
  networking.networkmanager = {
    enable = true;
    # Tried https://askubuntu.com/a/1228914 but it doesn't seem to help...
    wifi.scanRandMacAddress = false;
  };

  # Open ports in the firewall.
  # NOTE: Docker can override this with iptables...
  # https://github.com/NixOS/nixpkgs/issues/111852
  networking.firewall.allowedTCPPorts = [
    # pihole web interface
    80
    443

    # Deluge web interface
    8112

    # Plex media server
    32400
    3005
    8324
    32469

    # SMB share
    139
    445

    # Syncthing
    8384
    22000
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

    # Syncthing discovery
    21027
  ];


  # ==========================================================================
  # Service configuration
  # ==========================================================================
  services.cron.enable = true;
  services.openssh.enable = true;

  # For physical console access passwordless. Ideally this could use a hardware
  # key or something instead...
  services.getty.autologinUser = host.user;

  # Prevent lid sleep when plugged in
  services.logind.lidSwitchExternalPower = "ignore";

  /* Uncomment these to enable graphical desktop
    services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Keyboard options
    layout = "us";
    xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput.enable = true;

    # Enable the KDE Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    };
  # */

  # Maybe not needed anymore after tlp?
  services.mbpfan = {
    enable = true;
    aggressive = true;
    # verbose = true;
    /*
      settings.general = {
      min_fan1_speed = 3000;
      min_fan2_speed = 3000;
      };
    # */
  };

  # NOTE: this requires applesmc-next for kernel modules and TLP script
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 65;
    };
  };

  services.devmon.enable = true;

  # ==========================================================================
  # General system configuration
  # ==========================================================================

  nixpkgs.overlays = [
    (final: prev: {
      tlp = prev.tlp.overrideAttrs (prev': {
        buildInputs = prev'.buildInputs ++ [ applesmc-next ];
        postUnpack = (prev'.postUnpack or "") + "\n" +
          ''
            mkdir -p bat.d/
            cp ${applesmc-next.src.outPath}/45-apple $sourceRoot/bat.d/
          '';
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    docker
    hfsprogs
    lm_sensors
    powertop
  ];

  # TODO: use podman from unstable instead of docker?
  virtualisation.docker = {
    enable = true;
  };

  # ==========================================================================
  # User configuration
  # ==========================================================================
  users.users.${host.user} = {
    extraGroups = [
      # Allow managing network settings
      "networkmanager"
      # Groups for media server
      "docker"
      "deluge"
    ];
  };
}
