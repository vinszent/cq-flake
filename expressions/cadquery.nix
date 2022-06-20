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
  , casadi
  , ocp
  , ezdxf
  , ipython
  , typing-extensions
  , src
  , scipy
  , nptyping
  , typish
  , vtk_9
  , nlopt
  , multimethod
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

  doCheck = false;

  propagatedBuildInputs = [
    pyparsing
    casadi
    ocp
    ezdxf
    ipython
    typish
    typing-extensions
    scipy
    nptyping
    vtk_9
    nlopt
    multimethod
  ];

  # If the user wants extra fonts, probably have to add them here
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };

  # disabled = !(isPy3k && (pythonOlder "3.9"));

  checkInputs = [
    pytestCheckHook
    pytest-xdist
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
