{ 
  stdenv
  , buildPythonPackage
  , fetchFromGitHub
  , pytestCheckHook
  , pytest
  , setuptools_scm
}:

buildPythonPackage rec {
  version = "0.3.2";
  pname = "pytest-subtests";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = pname;
    rev = version;
    sha256 = "sha256-679Xjw+bXWjKQc+1SimsPkhtZ8lOcV7/p+My0u5fSlM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    setuptools_scm
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  propagatedBuildInputs = [
    pytest
  ];

  checkInputs = [
    pytestCheckHook
  ];

  meta = with stdenv.lib; {
    description = "unittest subTest() support and subtests fixture";
    homepage = "http://pytest.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
