{
  stdenv
  , lib
  , buildPythonPackage
  , fetchPypi
}:

buildPythonPackage rec {
  version = "16.4.0";
  pname = "path";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uvLnV8Sxm+ggj55n5I+0dbSld9VhNZDORmk7298IL1I=";
  };

  doCheck = false;

  meta = with lib; {
    description = "path implements path objects as first-class entities.";
    homepage = "https://github.com/jaraco/path";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

