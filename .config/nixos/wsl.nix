{ host, lib, ... }: {
  wsl = lib.mkIf host.wsl {
    wslConf.user.default = host.user;
  };
}
