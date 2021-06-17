{ lib
  , buildPythonPackage
  , isPy3k
  , pythonOlder
  , fetchFromGitHub
  , pyparsing
  , makeFontsConf
  , freefont_ttf
  , pytestCheckHook
  , pytest-xdist
  , ocp
  , ezdxf
  , ipython
  , typing-extensions
  , src
  , scipy
  , nptyping
  , vtk_9
}:

buildPythonPackage rec {
  pname = "cadquery";
  version = if (builtins.hasAttr "rev" src) then (builtins.substring 0 7 src.rev) else "local-dev";
  inherit src;

  propagatedBuildInputs = [
    pyparsing
    ocp
    ezdxf
    ipython
    typing-extensions 
    scipy
    nptyping
    vtk_9
  ];

  # If the user wants extra fonts, probably have to add them here
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };

  disabled = !(isPy3k && (pythonOlder "3.9"));

  checkInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  pytestFlagsArray = [
    "-W ignore::FutureWarning"
    "-n $NIX_BUILD_CORES"
  ];

  meta = with lib; {
    description = "Parametric scripting language for creating and traversing CAD models";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };
}
