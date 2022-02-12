{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytest
  , numpy
  , matplotlib
  , plotly
  , typish
}:

buildPythonPackage rec {
  version = "1.4.4";
  pname = "nptyping";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "ramonhagenaars";
    repo = "nptyping";
    rev = "v" + version;
    sha256 = "sha256-c9Qoufn9m3H03Pc8XhGzTBeixnl/elkalv50OrW4gJY=";
    fetchSubmodules = true;
  };

  patches = [
    ./remove-codestyle-deps.patch
  ];

  checkInputs = [
    pytest
  ];

  propagatedBuildInputs = [
    numpy
    typish
  ];

  pythonImportsCheck = [ "nptyping" ];

  meta = with lib; {
    description = "Type hints for Numpy";
    homepage = "https://github.com/ramonhagenaars/nptyping";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
