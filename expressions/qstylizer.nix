{
  stdenv
  , lib
  , buildPythonPackage
  , fetchFromGitHub
  , pytestCheckHook
  , pytest-mock
  , tinycss2
  , inflection
  , pbr
}:

buildPythonPackage rec {
  version = "0.2.1";
  pname = "qstylizer";

  src = fetchFromGitHub {
    owner = "blambright";
    repo = "qstylizer";
    rev = version;
    sha256 = "sha256-iEMxBpS9gOPubd9O8zpVmR5B7+UZJFkPuOtikO1a9v0=";
  };

  checkInputs = [ pytestCheckHook pytest-mock ];

  nativeBuildInputs = [ pbr ];

  PBR_VERSION = version;

  propagatedBuildInputs = [ tinycss2 inflection ];

  meta = with lib; {
    description = "Qt stylesheet generation utility for PyQt/PySide ";
    homepage = "https://github.com/blambright/qstylizer";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
