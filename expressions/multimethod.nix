{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pytest-cov
}:
buildPythonPackage rec {
  pname = "multimethod";
  rev = "fd95a144d5bccea0831a931b1cc2f29c29f74c61";
  version = "git-" + builtins.substring 0 7 rev;

  src = fetchFromGitHub {
    owner = "coady";
    repo = pname;
    inherit rev;
    sha256 = "KAMkhRSjonYegEGb/WXFoqEV0zq9VKrPLwHer6lNyIg=";
  };

  format = "pyproject";

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
