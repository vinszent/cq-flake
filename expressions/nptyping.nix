{ 
  stdenv
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytest
  , numpy
  , matplotlib
  , plotly
  , typish
  , pycodestyle
  , pylint
  , coverage
  , codecov
}:

buildPythonPackage rec {
  version = "1.3.0";
  pname = "nptyping";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "ramonhagenaars";
    repo = "nptyping";
    rev = "v" + version;
    sha256 = "sha256-/5tYBrJ8rzERhRG4HWqM32/TzbxizEcV+u9RXo9wuNg=";
    fetchSubmodules = true;
  };

  checkInputs = [
    pycodestyle
    pylint
    pytest
    coverage
    codecov
  ];

  propagatedBuildInputs = [
    numpy
    typish
  ];

  meta = with stdenv.lib; {
    description = "Type hints for Numpy";
    homepage = "https://github.com/ramonhagenaars/nptyping";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
