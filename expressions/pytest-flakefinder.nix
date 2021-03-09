{ stdenv, buildPythonPackage, lib, fetchFromGitHub, pytest }:

let rev = "a502101f4bc3c65cc32931218addc315b876cecb"; in 
buildPythonPackage {
  pname = "pytest-flakefinder";
  version = "git-" + builtins.substring 0 7 rev;

  src = fetchFromGitHub {
    owner = "dropbox";
    repo = "pytest-flakefinder";
    inherit rev;
    sha256 = "sha256-eL+lXAMWVO2LzCQBpTStPkp48ujK7HI+UtPHy6D5CH0=";
  };

  propagatedBuildInputs = [ pytest ];

  meta = with lib; {
    description = "Runs tests multiple times to expose flakiness";
    homepage = "https://github.com/dropbox/pytest-flakefinder";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
