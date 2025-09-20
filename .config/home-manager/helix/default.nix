{ ... }:
{
  theme = "monokai";

  editor = {
    bufferline = "multiple";
    rulers = [ 80 ];
    shell = [
      "fish"
      "-c"
    ];
    line-number = "relative";
    cursor-shape = {
      insert = "bar";
      select = "underline";
    };
  };
}
