{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytestCheckHook
  , typing-extensions
  , sphobjinv
  , sphinx
  , setuptools_scm
}:

buildPythonPackage rec {
  version = "1.12.0";
  pname = "sphinx-autodoc-typehints";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "agronholm";
    repo = "sphinx-autodoc-typehints";
    rev = version;
    sha256 = "sha256-hM4YIWsfEESaKaXg6Ds+XDUIz3Bi64RoMfBfnuBPdrM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    setuptools_scm
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  propagatedBuildInputs = [
    sphinx
  ];

  checkInputs = [
    pytestCheckHook
    typing-extensions
    sphobjinv
  ];

  # requires internet access
  disabledTests = [
    "format_annotation"
  ];

  meta = with lib; {
    description = "Type hints support for the Sphinx autodoc extension";
    homepage = "https://github.com/agronholm/sphinx-autodoc-typehints";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
