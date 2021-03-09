{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytestCheckHook
  , attrs
  , certifi
  , fuzzywuzzy
  , jsonschema
  , sphinx
  , sphinx_rtd_theme
  , stdio-mgr
  , sphinx-issues
  , pytest-subtests
  , flake8
}:

buildPythonPackage rec {
  version = "2.0.1";
  pname = "sphobjinv";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "bskinn";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-x/Fq6pGljKJ1uuHhV8R6J94tmfYxZ24J7jNVeQrfOTw=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    attrs
    certifi
    fuzzywuzzy
    jsonschema
  ];

  checkInputs = [
    pytestCheckHook
    sphinx
    sphinx_rtd_theme
    stdio-mgr
    sphinx-issues
    pytest-subtests
    flake8
  ];

  disabledTests = [
    "nonloc"
    "flake8_ext"
    "readme"
  ];

  # needs network access:
  # preCheck = ''
  #   echo "Building HTML doc for test phase"
  #   pushd .
  #   cd doc
  #   make html
  #   popd
  # '';

  meta = with lib; {
    description = "Toolkit for manipulation and inspection of Sphinx objects.inv files";
    homepage = "http://sphobjinv.readthedocs.io/en/latest/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
