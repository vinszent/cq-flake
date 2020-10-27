{ lib
  , buildPythonPackage
  , isPy3k
  , pythonOlder
  , fetchFromGitHub
  , pyparsing
  # , opencascade
  , stdenv
  , python
  , cmake
  , swig
  , ninja
  , smesh
  , freetype
  , libGL
  , libGLU
  , libX11
  , six
  , makeFontsConf
  , freefont_ttf
  , documentation ? false
  , sphinx
  , sphinx_rtd_theme
  , pytest
  , ocp
  , ezdxf
  , ipython
  , typing-extensions
  , src
  , scipy
  , nptyping
  , sphinx-autodoc-typehints
  , sphinxcadquery
}:

let 
  sphinx-build = if documentation then
    python.pkgs.sphinx.overrideAttrs (super: {
      propagatedBuildInputs = super.propagatedBuildInputs or [] ++ [ python.pkgs.sphinx_rtd_theme ];
      postFixup = super.postFixup or "" + ''
        # Do not propagate Python
        rm $out/nix-support/propagated-build-inputs
      '';
    }) else null;
  version = if (builtins.hasAttr "rev" src) then (builtins.substring 0 7 src.rev) else "local-dev";

in buildPythonPackage rec {
  pname = "cadquery";
  # version = "git-" + builtins.substring 0 7 src.rev;
  inherit src version;

  outputs = [ "out" ] ++ lib.lists.optional documentation "doc";

  # src = fetchFromGitHub {
  #   owner = "CadQuery";
  #   repo = pname;
  #   rev = 2d721d0ff8a195a0902eb9c3add88d07546c05b1;
  #   sha256 = "sha256-eMc7j41tkhtd47IZyaRjbHPBx/cVQSzoenUqak6OB6k=";
  # };

  nativeBuildInputs = lib.lists.optionals documentation [
    sphinx
    sphinx_rtd_theme
    sphinx-autodoc-typehints
    sphinxcadquery
  ];

  propagatedBuildInputs = [
    pyparsing
    ocp
    ezdxf
    ipython
    typing-extensions 
    scipy
    nptyping
  ];

  # If the user wants extra fonts, probably have to add them here
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };

  # Build errors on 2.7 and >=3.8 (officially only supports 3.6 and 3.7).
  # TODO recheck 3.8, I think that might be working now.
  disabled = !(isPy3k && (pythonOlder "3.8"));

  checkInputs = [
    pytest
  ];

  checkPhase = ''
    pytest -v
  '';

  # Documentation, very expensive so build after checkPhase
  preInstall = lib.optionalString documentation ''
    echo "Building CadQuery docs"
    PYTHONPATH=$PYTHONPATH:$(pwd) ./build-docs.sh
  '';

  postInstall = lib.optionalString documentation ''
    mkdir -p $out/share/doc
    cp -r target/docs/* $out/share/doc
  '';

  meta = with lib; {
    description = "Parametric scripting language for creating and traversing CAD models";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };
}
