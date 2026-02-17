{
  config,
  pkgs,
  ...
}:
let
  # https://github.com/nix-community/home-manager/issues/3514#issuecomment-1882897900
  createSymlink =
    localPath: config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/home-manager/${localPath}";
in
{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      package = pkgs.lixPackageSets.latest.nix-direnv;
    };

    config = {
      global = {
        strict_env = true;
        hide_env_diff = true;
        # https://github.com/direnv/direnv/wiki/Quiet-or-Silence-direnv
        # RIP, this was only implemented very recently and hasn't been released yet
        # https://github.com/direnv/direnv/pull/1336
        log_format = "\u001B[2mdirenv: %s\u001B[30m";
      };
    };

    # See ./direnv-hook.fish
    enableFishIntegration = true;
    # stdlib = builtins.readFile ./direnvrc;
  };

  xdg.configFile = {
    # backwards compat with older direnv
    "direnv/config.toml".source = config.xdg.configFile."direnv/direnv.toml".source;

    # for quick iteration
    "direnv/direnvrc".source = createSymlink "direnv/direnvrc";

    # TODO:
    # "fish/conf.d/52-direnv.fish".source = ./direnv-hook.fish;
  };
}
