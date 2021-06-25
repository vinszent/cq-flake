{ lib
  , stdenv
  , isPy3k
  , pythonOlder
  , fetchFromGitHub
  , cadquery
  , makeFontsConf
  , freefont_ttf
  , sphinx
  , sphinx_rtd_theme
  , src
  , sphinx-autodoc-typehints
  , sphinxcadquery
}:

let 
  sphinx-build = sphinx.overrideAttrs (super: {
      propagatedBuildInputs = super.propagatedBuildInputs or [] ++ [ sphinx_rtd_theme ];
      postFixup = super.postFixup or "" + ''
        # Do not propagate Python
        rm $out/nix-support/propagated-build-inputs
      '';
    });
  version = if (builtins.hasAttr "rev" src) then (builtins.substring 0 7 src.rev) else "local-dev";

in stdenv.mkDerivation rec {
  pname = "cq-docs";
  inherit src version;

  nativeBuildInputs = [
    cadquery
    sphinx
    sphinx_rtd_theme
    sphinx-autodoc-typehints
    sphinxcadquery
  ];

  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };

  disabled = !(isPy3k && (pythonOlder "3.9"));

  buildPhase = ''
    echo "Building CadQuery docs"
    export PYTHONPATH=$PYTHONPATH:$(pwd)
    cd doc
    sphinx-build -b html . _build/html
  '';

  installPhase = ''
    mkdir -p $out/share/doc
    cp -r _build/html/* $out/share/doc/
  '';

  meta = with lib; {
    description = "HTML documentation for CadQuery";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
