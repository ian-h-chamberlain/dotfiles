/**
  A module for setting default application handlers.

  One day I might try upstreaming this to somewhere or at least making it
  more standalone without the actual configuration.

  NOTE: there is no real way to "revert to default", except maybe uninstalling
  the app assigned to handle something, so if you care about restoring details
  you may want to create a backup of `swda getUTIs` output somewhere.
*/
{ lib, pkgs, ... }:
let
  /**
    Supported keys:
    - bundle identifier (e.g. "org.gnu.Emacs")
    - full application path e.g. "/Application/Emacs.app"
    - app name e.g. "Emacs"

    Supported values:
    - UTI <https://developer.apple.com/documentation/uniformtypeidentifiers>
    - TODO: maybe also support URL schemes, mail, etc.

    Not supported :
    - dynamic UTIs: https://github.com/Lord-Kamina/SwiftDefaultApps/issues/53

    To find the UTIs for a given file (most -> least specific):
    - `mdls -name kMDItemContentTypeTree $file`
  */
  defaultApps = {
    # Partially generated with `swda getUTIs | grep "$APP" | cut -f1 | jq -R`
    # in an attempt to find all plaintext/source code.
    "com.microsoft.VSCode" = [
      #region VSCode defaults
      # Set here just to make sure any other app doesn't take over handling these
      # when it's installed (e.g. other text editors/IDEs etc.)
      "com.adobe.edn"
      "com.adobe.jsx"
      "com.apple.applescript.script"
      "com.apple.applescript.script-bundle"
      "com.apple.applescript.text"
      "com.apple.ascii-property-list"
      "com.apple.file-system-plug-in"
      "com.apple.traditional-mac-plain-text"
      "com.barebones.bbedit.ini-configuration"
      "com.barebones.bbedit.scss-source"
      "com.docker.dockerfile"
      "com.macromates.textmate.config-file"
      "com.microsoft.code-workspace"
      "com.microsoft.csharp-source"
      "com.microsoft.f-sharp"
      "com.microsoft.vb-source"
      "com.microsoft.xaml"
      "com.netscape.javascript-source"
      "net.daringfireball.markdown"
      "org.bash.source"
      "org.clojure.script"
      "org.cmake.cmake"
      "org.codehaus.groovy-source"
      "org.coffee.source"
      "org.go.source"
      "org.khronos.glsl.fragment-shader"
      "org.lesscss.less"
      "org.n8gray.bat"
      "org.n8gray.diff-script"
      "org.n8gray.ini-source"
      "org.n8gray.makefile"
      "org.n8gray.railstemplate"
      "org.n8gray.structured-query-language-source"
      "org.nodejs.cjs"
      "org.ocaml.ocaml-interface"
      "org.ocaml.ocaml-source"
      "org.perl.test-script"
      "org.python.restructuredtext"
      "org.rubygems.gemspec"
      "org.rust-lang.rust"
      "org.rust-lang.source"
      "org.sbarex.dart"
      "org.sbarex.ms-powershell"
      "org.sbarex.ms-powershell-module"
      "org.sbarex.ms-powershell-module-manifest"
      "org.vuejs.vue"
      "public.c-header"
      "public.c-plus-plus-source"
      "public.c-source"
      "public.comma-separated-values-text"
      "public.css"
      "public.data"
      "public.gd"
      "public.json"
      "public.mpeg-2-transport-stream"
      "public.patch-file"
      "public.plain-text"
      "public.properties"
      "public.python-script"
      "public.shell-script"
      "public.swift-source"
      "public.symlink"
      "public.tsx"
      "public.utf8-plain-text"
      "public.yaml"
      #endregion

      #region TextEdit defaults
      "com.adobe.acrobat.sequ"
      "com.adobe.actionscript"
      "com.adobe.coldfusion"
      "com.adobe.fea"
      "com.adobe.mxml"
      "com.apple.audio-unit-preset"
      "com.apple.chess.pgn"
      "com.apple.device-model-code"
      "com.apple.dt.document.scheme"
      "com.apple.haptics.ahap"
      "com.apple.music.metadata"
      "com.apple.nspboard-type"
      "com.apple.ostype"
      "com.apple.printcenter.jobids"
      "com.apple.structured-text"
      "com.apple.structured-text.address"
      "com.apple.structured-text.date"
      "com.apple.structured-text.telephone-number"
      "com.apple.structured-text.transit-information"
      "com.apple.tv.m3u-playlist"
      "com.apple.tv.metadata"
      "com.eiffel.eiffelstudio-project-config"
      "com.eiffel.source-code"
      "com.glyphsapp.glyphs2license"
      "com.google.earth.kml"
      "com.jetbrain.source"
      "com.macromates.textmate.cgi-script"
      "com.microsoft.hlsl"
      "com.microsoft.windows-media-wax"
      "com.microsoft.windows-media-wmx"
      "com.microsoft.windows-media-wvx"
      "com.real.ram"
      "com.sas.source"
      "com.scenarist.closed-caption"
      "com.schriftgestaltung.glyphslicense"
      "com.schriftgestaltung.metrics"
      "com.sun.javafx"
      "com.sun.manifest"
      "com.symfony.twig"
      "info.haml.haml"
      "org.applescript.source"
      "org.cson.source"
      "org.dlang.d"
      "org.erlang.erlang-source"
      "org.fish.source"
      "org.fonttools.ttx"
      "org.gcc.files"
      "org.inno.source"
      "org.json.jsonc"
      "org.jsonlines.jsonl"
      "org.julialang.julia"
      "org.khronos.collada.digital-asset-exchange"
      "org.khronos.gltf"
      "org.km3"
      "org.kmt.source"
      "org.microsoft.inf"
      "org.mpeg.mpd"
      "org.n8gray.awk"
      "org.n8gray.scheme-source"
      "org.n8gray.standard-ml-source"
      "org.n8gray.verilog"
      "org.n8gray.vhdl"
      "org.nfo"
      "org.omg.ecore"
      "org.pddl.pddl"
      "org.racket-lang.source"
      "org.ruby-lang.eruby"
      "org.rubyonrails.erb-sql"
      "org.sbarex.conf"
      "org.sbarex.nim"
      "org.scala.source"
      "org.vim.vim-script"
      "org.w3.webvtt"
      "org.w3.wsdl"
      "public.bluetooth-vendor-product-id"
      "public.c-plus-plus-inline-header"
      "public.c-plus-plus-source.preprocessed"
      "public.c-source.preprocessed"
      "public.case-insensitive-text"
      "public.delimited-values-text"
      "public.dylan-source"
      "public.filename-extension"
      "public.gdshader"
      "public.lex-source"
      "public.mime-type"
      "public.ndjson"
      "public.objective-c-plus-plus-source.preprocessed"
      "public.objective-c-source.preprocessed"
      "public.protobuf-source"
      "public.rss"
      "public.source-code.preprocessed"
      "public.text"
      "public.utf16-external-plain-text"
      "public.utf8-tab-separated-values-text"
      "public.xfd"
      "public.yacc-source"
      #endregion

      #region plists
      "com.apple.ascii-property-list"
      "com.apple.binary-property-list"
      "com.apple.dt.document.ascii-property-list"
      "com.apple.dt.document.script-suite-property-list"
      "com.apple.dt.document.script-terminology-property-list"
      "com.apple.property-list"
      "com.apple.xcode.app-privacy-property-list"
      "com.apple.xcode.code-requirement-property-list"
      "com.apple.xcode.entitlements-property-list"
      "com.apple.xml-property-list"
      #endregion

      #region Emacs files
      "com.macromates.textmate.lisp"
      "com.microsoft.word.wordml"
      "com.microsoft.word.wordprocessingml"
      "com.sun.java-source"
      "com.unknown.md"
      "edu.uo.texshop.tex"
      "org.asm.source"
      "org.haskell.haskell-source"
      "org.haskell.literate-haskell-source"
      "org.lua.lua-source"
      "org.n8gray.idl"
      "org.n8gray.jsp-source"
      "org.n8gray.lisp"
      "org.n8gray.xhtml"
      "org.r-project.r"
      "org.rdf.source"
      "org.tug.tex.bibtex"
      "org.w3.css"
      "org.w3.xml-dtd"
      "org.w3.xsl"
      "org.xml-tools.source"
      "org.xsd.schema"
      "org.xul.source"
      "org.yaml.yaml"
      "public.ada-source"
      "public.fortran-77-source"
      "public.fortran-90-source"
      "public.fortran-95-source"
      "public.fortran-source"
      "public.pascal-source"
      "public.utf16-plain-text"
      "tk.tcl.tcl-source"
      #endregion

      #region Xcode files
      # Mostly left as default, but all public.* are set to vscode here
      "org.khronos.glsl-source"
      "org.khronos.glsl.geometry-shader"
      "org.khronos.glsl.tess-control-shader"
      "org.khronos.glsl.tess-evaluation-shader"
      "org.khronos.glsl.vertex-shader"
      "public.assembly-source"
      "public.bash-script"
      "public.c-plus-plus-header"
      "public.csh-script"
      "public.geojson"
      "public.geometry-definition-format"
      "public.ksh-script"
      "public.make-source"
      "public.mig-source"
      "public.module-map"
      "public.nasm-assembly-source"
      "public.objective-c-plus-plus-source"
      "public.objective-c-source"
      "public.opencl-source"
      "public.perl-script"
      "public.php-script"
      "public.polygon-file-format"
      "public.precompiled-c-header"
      "public.precompiled-c-plus-plus-header"
      "public.ruby-script"
      "public.script"
      "public.source-code"
      "public.standard-tesselated-geometry-format"
      "public.tcsh-script"
      "public.xml"
      "public.zsh-script"
      #endregion

      #region Miscellaneous
      "com.apple.log"
      "com.apple.terminal.shell-script"
      "com.barebones.bbedit.tex-source"
      "com.stata.source"
      "dev.nix.source"
      "dev.svelte.source"
      "io.nextflow.source"
      "org.bazel.source"
      "org.crystal-lang.source"
      "org.elixir-lang.source"
      "org.opml.source"
      "org.sagemath.source"
      "org.smali.source"
      "org.soliditylang.source"
      "org.videolan.dts" # Linux devicetree files are treated as this, unfortunately.
      "public.log"
      "public.xhtml"
      #endregion

      #region Dynamic UTIs
      # See https://stackoverflow.com/q/8003919/14436105 for more info
      "dyn.ah62d4rv4ge80e8xq" # *.bzl
      "dyn.ah62d4rv4ge80w5xm" # *.ini (for certain files like tox.ini, pytest.ini)
      "dyn.ah62d4rv4ge81e3pn" # *.rej
      "dyn.ah62d4rv4ge81g6dfqq" # *.spec
      "dyn.ah62d4rv4ge80k7dxre" # *.dtsi
      #endregion
    ];

    # Most things I want to open in VSCode, but these few are more emacs-specific.
    "org.gnu.Emacs" = [
      "org.orgmode.org"
      "org.gnu.emacs-lisp"
      "org.gnu.emacs-lisp-object"
    ];

    "com.apple.TextEdit" = [
      "com.apple.rtfd"
      "public.rtf"
      "org.oasis-open.opendocument.text"
      "org.oasis-open.opendocument.text-template"
      "org.openoffice.text"
      "org.openoffice.text-template"
      "org.openxmlformats.wordprocessingml.document"
    ];

    "com.apple.Automator" = [
      "com.apple.shortcuts.workflow-file"
    ];
  };

  swda = "${pkgs.swiftdefaultapps}/bin/swda";

  # TODO: might make sense to write this to a separate file, it's v noisy
  activationCmds = with lib; (flatten (mapAttrsToList
    (app: utis:
      map
        (uti: ''run --quiet ${swda} setHandler --app "${app}" --UTI "${uti}"'')
        utis
    )
    defaultApps));
in
{
  # TODO: maybe always add swda to pkgs ? Also should probably assert isDarwin if upstreamed
  home.activation.setDarwinDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    verboseEcho "Configuring macOS default applications"
    ${lib.concatStringsSep "\n" activationCmds}
  '';
}
