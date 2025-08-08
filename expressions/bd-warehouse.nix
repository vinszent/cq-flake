{
  lib
  , python
  , buildPythonPackage
  , fetchFromGitHub
  , setuptools
  , setuptools-scm
  , build123d
  , pytestCheckHook
}:
buildPythonPackage rec {
  pname = "bd_warehouse";
  rev = "97112a02d9538d57740a005a7802dd149d797568";
  version = "0.0dev";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = "bd_warehouse";
    inherit rev;
    sha256 = "sha256-ATNEYlQ410Gjaa1LDXeqWTMXTx8xucWAi/gOeBJMXbg="; #lib.fakeHash;
  };

  pyproject = true;
  build-system = [ setuptools ];

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ build123d ];
  # checkInputs = [ pytestCheckHook ];
}
