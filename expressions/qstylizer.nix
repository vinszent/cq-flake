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
  version = "0.2.2";
  pname = "qstylizer";

  src = fetchFromGitHub {
    owner = "blambright";
    repo = "qstylizer";
    rev = version;
    sha256 = "sha256-QJ4xhaAoVO4/VncXKzI8Q5f/rPfctJ8CvfedkQVgZgQ=";
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
