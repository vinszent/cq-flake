{ 
  stdenv
  , lib
  , buildPythonPackage
  , fetchFromGitHub
  , pytestCheckHook
  , sphinx
}:

buildPythonPackage rec {
  version = "1.2.0";
  pname = "sphinx-issues";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = pname;
    rev = version;
    sha256 = "sha256-pOis2V9h2/C5mO9h/Jr/coMbMPSIc66/p6Sdy0i1gaE=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    sphinx
  ];

  checkInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "A Sphinx extension for linking to your project's issue tracker";
    homepage = "https://github.com/sloria/sphinx-issues/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
