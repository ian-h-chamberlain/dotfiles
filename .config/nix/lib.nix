# Helper functions that aren't in upstream nixpkgs.lib. It would be nice
# for this to be usable as a module that extends nixpkgs.lib for the
# appropriate `pkgs`, but for now `self.lib` is good enough
{ self, lib, ... }:
{
  /**
    Return the given value if non-null, otherwise the given `default`
  */
  unwrapOr = default: v: if v == null then default else v;

  /**
    Filter a list of paths to include only those that actually exist
  */
  existingPaths = builtins.filter builtins.pathExists;

  /**
    Enable "escape sequences" in a string by (ab)using the builtin Nix JSON parser.
         For readability / sanity, this should probably only ever be used with a
         single-quoted '' literals for backslashes to work as expected.
         <https://github.com/NixOS/nix/issues/10082>
  */
  unescape =
    s:
    let
      escaped = builtins.replaceStrings [ "\"" ] [ "\\\"" ] s;
    in
    builtins.fromJSON ''"${escaped}"'';

  /**
    com.apple.dock helpers
  */
  dock = with self.lib.dock; {
    path-entry = path: {
      tile-data = {
        file-data = {
          _CFURLString = "${path}";
          _CFURLStringType = 0;
        };
      };
    };

    folder =
      path:
      lib.recursiveUpdate (path-entry path) {
        tile-data = {
          # Show as folder icon instead of stack etc.
          displayas = 1;
          # Use default appearance for contents, set 2 to force grid here
          showas = 0;
        };
        tile-type = "directory-tile";
      };

    app-in-dir = dir: appName: path-entry "${dir}/${appName}.app";
    system-app = app-in-dir "/System/Applications";
    small-spacer = {
      tile-data = { };
      tile-type = "small-spacer-tile";
    };
  };

  /**
    Helper for issues with SSL certificates on various platforms.
    - https://github.com/NixOS/nixpkgs/issues/66716
    - https://github.com/NixOS/nixpkgs/issues/210223

    Not which are needed / relevant all the time, but I've seen a bunch
    of various resources refer to one or multiple of these...
  */
  sslCertEnv = caBundle: {
    NIX_SSL_CERT_FILE = caBundle;
    SSL_CERT_FILE = caBundle;
    REQUESTS_CA_BUNDLE = caBundle;
    SYSTEM_CERTIFICATE_PATH = caBundle;
    GIT_SSL_CAINFO = caBundle;
  };
}
