{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.helix;

  helixVim = builtins.fromTOML (builtins.readFile ./helix-vim.toml);
in
{
  options.programs.helix.vimMode = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use vim-like bindings for helix.
      See <https://github.com/LGUG2Z/helix-vim/blob/master/config.toml> for details.
    '';
  };

  config.programs.helix.settings.keys = lib.mkIf cfg.vimMode helixVim.keys;
}
