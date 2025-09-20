{ lib, ... }:
{
  /*
  networking = {
    # https://github.com/NixOS/nixpkgs/issues/10909#issuecomment-1009554439
    # NOTE this seems to require a manual start of the systemd service for some reason
    macvlans.wsl0.interface = "eth0";
    interfaces."wsl0".ipv4.addresses = [{
      # For use with https://gist.github.com/wildlarva/0539212ad6bf0bf1450b38726e1a42de
      address = "192.168.100.2";
      prefixLength = 24;
    }];
  };
  */
}
