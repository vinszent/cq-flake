{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
}:

buildPythonPackage rec {
  version = "1.9.3";
  pname = "typish";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "ramonhagenaars";
    repo = "typish";
    rev = "v" + version;
    sha256 = "sha256-LnOg1dVs6lXgPTwRYg7uJ3LCdExYrCxS47UEJxKHhVU=";
    fetchSubmodules = true;
  };

  # checks have a circular dependency with nptyping
  doCheck = false; 

  meta = with lib; {
    description = "For more control over your types";
    homepage = "https://github.com/ramonhagenaars/typish";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
