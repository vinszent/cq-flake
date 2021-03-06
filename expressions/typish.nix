{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
}:

buildPythonPackage rec {
  version = "1.7.0";
  pname = "typish";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "ramonhagenaars";
    repo = "typish";
    rev = version;
    sha256 = "sha256-CYovcyRe2YnbwE04DDQ6ebOIP81PtOVNiOK3o+Vfwto=";
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
