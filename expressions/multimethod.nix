{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "multimethod";
  version = "1.8";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "coady";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-JuP1qGlrSffoQ6rRnf896K8PwqHEHiskmH8rd53qcdc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "multimethod"
  ];

  meta = with lib; {
    description = "Multiple argument dispatching";
    homepage = "https://github.com/coady/multimethod";
    license = licenses.asl20;
    maintainers = teams.determinatesystems.members;
  };
}
