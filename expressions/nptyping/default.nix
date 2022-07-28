{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytest
  , numpy
  , typing-extensions
  , matplotlib
  , plotly
  , typish
  , typeguard
  , beartype
  , mypy
}:

buildPythonPackage rec {
  version = "2.0.1";
  pname = "nptyping";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "ramonhagenaars";
    repo = "nptyping";
    rev = "v" + version;
    sha256 = "sha256-f4T2HpPb+Z+r0rjhh9sdDhVe8jnelHzPrA0axEuRckY=";
    fetchSubmodules = true;
  };

  # Remove install test
  patchPhase = ''
    rm tests/test_wheel.py
  '';

  checkInputs = [
    pytest
    typeguard
    beartype
    mypy
  ];

  propagatedBuildInputs = [
    numpy
    typish
    typing-extensions
  ];

  pythonImportsCheck = [ "nptyping" ];

  meta = with lib; {
    description = "Type hints for Numpy";
    homepage = "https://github.com/ramonhagenaars/nptyping";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
