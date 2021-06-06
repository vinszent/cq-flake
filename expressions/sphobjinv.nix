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
  , pytest-subtests
  , flake8
  , dictdiffer
  , pytest-check
}:

buildPythonPackage rec {
  version = "2.1";
  pname = "sphobjinv";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "bskinn";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-7uEjTz0/D7Sv1CnOz/Fry16SjMfEUA4dXYifH0pFhyM=";
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
    pytest-subtests
    flake8
    dictdiffer
    pytest-check
  ];

  disabledTests = [
    "nonloc"
    "flake8_ext"
    "readme"
    "cli_invocations"
  ];

  meta = with lib; {
    description = "Toolkit for manipulation and inspection of Sphinx objects.inv files";
    homepage = "http://sphobjinv.readthedocs.io/en/latest/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
