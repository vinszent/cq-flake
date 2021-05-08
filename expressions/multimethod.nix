{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pytest-cov
}:
buildPythonPackage rec {
  pname = "multimethod";
  rev = "aa99df03e0d5254f2bfee440477aeed6621e50bb";
  version = "git-" + builtins.substring 0 7 rev;

  src = fetchFromGitHub {
    owner = "coady";
    repo = pname;
    inherit rev;
    sha256 = "sha256-lEfJo9s3OrX6hqeuuyTajXbMWUHb9K/eYAzFzQdjEhM=";
  };

  checkInputs = [
    pytestCheckHook
    pytest-cov
  ];

  pythomImportsCheck = [
    "multimethod"
  ];

  meta = with lib; {
    description = "Multiple argument dispatching";
    homepage = "https://github.com/coady/multimethod";
    license = licenses.asl20;
    maintainers = teams.determinatesystems.members;
  };
}
