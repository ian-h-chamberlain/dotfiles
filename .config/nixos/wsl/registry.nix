{ host, lib, pkgs, ... }:
let
  quoteString = s: "\"" + (lib.escape [ "\"" ] s) + "\"";

  # https://support.microsoft.com/en-us/topic/how-to-add-modify-or-delete-registry-subkeys-and-values-by-using-a-reg-file-9c7f37cf-a5e9-e1cd-c4fa-2a26218a1a23#ID0EDJBD
  dataTypePrefixes = {
    REG_BINARY = "hex"; # aka hex(3)
    REG_DWORD = "dword"; # integer, can also use hex(4) for LE or hex(5) for BE
    REG_EXPAND_SZ = "hex(2)"; # UTF-16LE NUL-terminated string
    REG_MULTI_SZ = "hex(7)"; # UTF-16LE NUL-terminated string
    REG_SZ = "";
  };

  # Input: prefix e.g. "hex(2)", string e.g. "hello there"
  # Output: reg format hex string e.g. "hex(2):22,00,43,00,3a,00,5c,00,55,00,73,00,65,00,72,00"
  mkHexString = prefix: s:
    let
      toHexStringWithZero = s:
        let
          hex = lib.toLower (lib.toHexString s);
        in
        (lib.strings.replicate (2 - (builtins.stringLength hex)) "0") + hex;

      asciiValues = (builtins.map lib.strings.charToInt (lib.stringToCharacters s)) ++ [ 0 ];
      utf16Values = builtins.map toHexStringWithZero (lib.concatMap
        # LE: ascii byte comes before upper 0 byte
        (x: [ x 0 ])
        asciiValues
      );
    in
    (if prefix != "" then prefix + ":" else "")
    + builtins.concatStringsSep "," utf16Values
  ;

  mkRegEntry = lib.generators.mkKeyValueDefault {
    mkValueString = v:
      if builtins.isAttrs v then
      # TODO handle nested attr sets etc
        mkHexString dataTypePrefixes.${v._type or "REG_SZ"} v
      else if builtins.isString v then
        quoteString v
      else
        lib.generators.mkValueStringDefault { } "=";
  };

  # TODO: still need to handle hex(2) and stuff...
  mkRegEntries = entries: lib.generators.toINI
    {
      mkKeyValue = key: value:
        if builtins.isAttrs value then
          mkRegEntry key value
        else
        # Need to handle numbers or other things differently here?
          mkRegEntry key { "@" = value; }
      ;
    }
    entries;

  writeRegFile = name: entries: pkgs.writeText name ''
    Windows Registry Editor Version 5.00

    ${mkRegEntries entries}
  '';

  # Should eventually add the _type member here, or maybe just do the conversion itself?
  REG_EXPAND_SZ = text: null;

  quotedCmd = lib.concatMapStringsSep " " quoteString;

  aRegFile =
    let
      pythonw = quotedCmd [
        ''C:\Users\CHAMI008\scoop\apps\python\current\pythonw.exe''
        ''C:\Users\CHAMI008\Documents\tools\code.pyw''
        ''%1''
      ];
    in
    writeRegFile "vscode_classes.reg" {
      ${''HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\VSCode\command''} = { "@" = REG_EXPAND_SZ pythonw; };
      ${''HKEY_CURRENT_USER\SOFTWARE\Classes\directory\background\shell\VSCode\command''} = REG_EXPAND_SZ pythonw;
      # this would be hella cool but not sure if it's feasible... toGitINI does something similar:
      # https://github.com/hsjobeki/nixpkgs/blob/96a1ff01e43aee606027916d302f6ad82621806b/lib/generators.nix#L380C1-L380C62
      HKEY_CURRENT_USER.SOFTWARE.Classes.Drive.shell.VSCode.command = REG_EXPAND_SZ pythonw;

      HKEY_CURRENT_USER.SOFTWARE.Classes.vscode.shell.open.command = pythonw;
    };
in
{ }
