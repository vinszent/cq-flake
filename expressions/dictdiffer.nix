{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytestCheckHook
  , setuptools_scm
  , pytest-runner
}:

buildPythonPackage rec {
  version = "0.8.1";
  pname = "dictdiffer";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "inveniosoftware";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-jIGmP8PiXjjvtSnBfrv3B6VZdcWMqmaAWMz+sLsp0zs=";
  };

  postPatch = ''
    substituteInPlace pytest.ini \
      --replace "--pep8 " ""\
      --replace "--cov=dictdiffer --cov-report=term-missing " ""
  '';

  nativeBuildInputs = [
    setuptools_scm
  ];

  postConfigure = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

  propagatedBuildInputs = [
  ];

  checkInputs = [
    pytestCheckHook
    pytest-runner
  ];

  disabledTests = [
  ];

  meta = with lib; {
    description = "Python module to help diff and patch dictionaries.";
    homepage = "https://github.com/inveniosoftware/dictdiffer";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
