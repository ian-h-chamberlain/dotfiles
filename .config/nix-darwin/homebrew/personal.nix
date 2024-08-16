{ config, host, ... }:
{
  homebrew = {
    caskArgs.appdir = "${config.users.users.${host.user}.home}/Applications";
    casks = [
      "mullvadvpn"
    ];
  };
}
