{ self, lib, config, pkgs, ... }:
let
  # This is hella messy and probably not really how you're supposed to use this,
  # but by importing the nix-darwin module and passing it all the right args it looks
  # like we can get x86 brew to install a different set of packages.
  #
  # I probably ought to do this with some custom options or something instead
  # of just a let-binding but this will do for now...
  x86_64-brew = import "${self.inputs.nix-darwin}" {
    nixpkgs = self.inputs.nixpkgs;
    inherit pkgs;

    # Not sure if this is really necessary, but it feels more "right". Maybe
    # I can omit the explicit brewPrefix with it in place, or something...
    system = "x86_64-darwin";

    configuration.homebrew = {
      inherit (config.homebrew) enable global taps;
      onActivation = {
        inherit (config.homebrew.onActivation) cleanup extraFlags;
      };

      brewPrefix = "/usr/local/bin";
      brews = [
        "bazelisk"
      ];
    };
  };

  # This seems kinda hacky, but I guess it works??
  activateHomebrew = pkgs.writeScript "activate-x86_64-brew" ''
    #!/usr/bin/env bash
    echo -n "x86_64 " >&2
    ${x86_64-brew.config.system.activationScripts.homebrew.text}
  '';
in
{
  # Inject the x86_64 brew activation into our top-level darwin activation
  # Technically `activationScripts.homebrew` is kind of an implementation detail
  # but it's probably fine... see e.g. https://github.com/LnL7/nix-darwin/pull/664
  system.activationScripts.homebrew.text = lib.mkAfter "arch -x86_64 ${activateHomebrew}";
}
