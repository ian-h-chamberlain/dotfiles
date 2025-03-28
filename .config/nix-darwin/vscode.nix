{ lib, host, ... }:
let
  # TODO: it would be nice to upstream this and/or figure out a way to call
  # this helper from upstream instead of reimplementing:
  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  mkBrewfileSectionString = heading: entries: lib.optionalString (entries != [ ]) ''

    # ${heading}
    ${lib.concatMapStringsSep "\n" (v: v.brewfileLine or v) entries}

  '';

  extensions = [
    "13xforever.language-x86-64-assembly"
    "Alpha4.jsonl"
    "anseki.vscode-color"
    "asvetliakov.vscode-neovim"
    "bierner.emojisense"
    "bierner.markdown-checkbox"
    "bierner.markdown-mermaid"
    "bmalehorn.vscode-fish"
    "bpruitt-goddard.mermaid-markdown-syntax-highlighting"
    "caponetto.vscode-diff-viewer"
    "codezombiech.gitignore"
    "dan-c-underwood.arm"
    "DavidAnson.vscode-markdownlint"
    "dfarley1.file-picker"
    "DotJoshJohnson.xml"
    "drcika.apc-extension"
    "dunstontc.viml"
    "eamodio.gitlens"
    "emeraldwalk.RunOnSave"
    "esbenp.prettier-vscode"
    "GitHub.vscode-pull-request-github"
    "golang.go"
    "Gruntfuggly.todo-tree"
    "haskell.haskell"
    "IBM.output-colorizer"
    "iliazeus.vscode-ansi"
    "ivhernandez.vscode-plist"
    "jasonnutter.vscode-codeowners"
    "jbenden.c-cpp-flylint"
    "jeff-hykin.better-cpp-syntax"
    "jinliming2.vscode-go-template"
    "jnoortheen.nix-ide"
    "johnnymorganz.stylua"
    "josetr.cmake-language-support-vscode"
    "joshuapoehls.json-escaper"
    "justusadam.language-haskell"
    "llvm-vs-code-extensions.vscode-clangd"
    "mads-hartmann.bash-ide-vscode"
    "mariusschulz.yarn-lock-syntax"
    "mattn.Lisp"
    "mechatroner.rainbow-csv"
    "ms-azuretools.vscode-docker"
    "ms-dotnettools.vscode-dotnet-runtime"
    "ms-python.black-formatter"
    "ms-python.debugpy"
    "ms-python.isort"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode.cmake-tools"
    "ms-vscode.hexeditor"
    "ms-vscode.live-server"
    "ms-vscode.remote-explorer"
    "ms-vscode.vscode-serial-monitor"
    "ms-vsliveshare.vsliveshare"
    "pierre-payen.gdb-syntax"
    "redhat.vscode-commons"
    "redhat.vscode-xml"
    "redhat.vscode-yaml"
    "richie5um2.vscode-sort-json"
    "RReverser.llvm"
    "rust-lang.rust-analyzer"
    "ryanluker.vscode-coverage-gutters"
    "samuelcolvin.jinjahtml"
    "semanticdiff.semanticdiff"
    "Shopify.ruby-lsp"
    "sleistner.vscode-fileutils"
    "streetsidesoftware.code-spell-checker"
    "sumneko.lua"
    "tamasfe.even-better-toml"
    "timonwong.shellcheck"
    "twxs.cmake"
    "Tyriar.sort-lines"
    "vadimcn.vscode-lldb"
    "vscode-org-mode.org-mode"
    "vstirbu.vscode-mermaid-preview"
    "webfreak.cute-theme"
    "webfreak.debug"
    "wholroyd.jinja"
    "xaver.clang-format"
    "yy0931.gitconfig-lsp"
    "ZixuanWang.linkerscript"
  ] ++ extensionsByClass.${host.class} or [ ];

  extensionsByClass = {
    work = [
      "atlassian.atlascode"
      "BazelBuild.vscode-bazel"
      "GitHub.copilot-chat"
      "GitHub.copilot"
      "ian-h-chamberlain.rpm-specfile"
      "korekontrol.saltstack"
      "marko2276.yang"
      "plorefice.devicetree"
      "robocorp.robotframework-lsp"
      "Veracosta.mib"
      "warpnet.salt-lint"
      "warpnet.saltstack-extension-pack"
      "zxh404.vscode-proto3"
    ];
    personal = [
      "a5huynh.vscode-ron"
      "corewa-rs.redcode"
      "github.vscode-github-actions"
      "ian-h-chamberlain.pica200"
      "karunamurti.tera"
      "mesonbuild.mesonbuild"
      "nico-castell.linux-desktop-file"
      "PolyMeilex.wgsl"
      "slevesque.shader"
      "vgalaktionov.moonscript"
    ];
  };

in
{
  # NOTE: AFAIK this requires a `code` executable to be available at activation
  # time, which likely means either `visual-studio-code` needs to be added as a
  # cask or `programs.vscode.enable = true`. Not sure if the latter works equally well.
  homebrew.extraConfig = mkBrewfileSectionString "VSCode Extensions"
    (builtins.map (n: ''vscode "${n}"'') extensions);
}
