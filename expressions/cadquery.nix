{ lib
  , buildPythonPackage
  , setuptools_scm
  , isPy3k
  , pythonOlder
  , fetchFromGitHub
  , pyparsing
  , makeFontsConf
  , freefont_ttf
  , pytestCheckHook
  , pytest-xdist
  , ocp
  , casadi
  , ezdxf
  , ipython
  , typing-extensions
  , src
  , scipy
  , nptyping
  , typish
  , vtk
  , nlopt
  , multimethod
  , docutils
}:

buildPythonPackage rec {
  pname = "cadquery";
  version = if (builtins.hasAttr "rev" src) then (builtins.substring 0 7 src.rev) else "local-dev";
  inherit src;

  SETUPTOOLS_SCM_PRETEND_VERSION = "${version}";

  nativeBuildInputs = [ setuptools_scm ];

  patchPhase = ''
    substituteInPlace setup.py \
      --replace "cadquery-ocp" "ocp"
  '';

  propagatedBuildInputs = [
    pyparsing
    ocp
    ezdxf
    casadi
    ipython
    typing-extensions
    scipy
    nptyping
    typish
    vtk
    nlopt
    multimethod
  ];

  # If the user wants extra fonts, probably have to add them here
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };

  disabled = !isPy3k;

  checkInputs = [
    pytestCheckHook
    pytest-xdist
    docutils
  ];

  pytestFlagsArray = [
    "-W ignore::FutureWarning"
    "-n $NIX_BUILD_CORES"
    "-k 'not example'"
  ];

  meta = with lib; {
    description = "Parametric scripting language for creating and traversing CAD models";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };
}
