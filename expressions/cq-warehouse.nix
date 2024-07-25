{
  lib
  , python
  , buildPythonPackage
  , fetchFromGitHub
  , cadquery
  , setuptools
}:
buildPythonPackage rec {
  pname = "cq-warehouse";
  rev = "56fa36e2480fc510ac5dd3e60873bdb9797e9abe";
  version = "git+56fa36e";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = "cq_warehouse";
    inherit rev;
    sha256 = "sha256-RHiQqmQ5+1IRd9gqlBsgBErmKy6Eo5XHrvRyNf+1m/4=";
  };

  build-system = [ setuptools ];

  format = "pyproject";

  propagatedBuildInputs = [ cadquery ];

  checkPhase = ''
    ${python.interpreter} -m unittest tests
  '';
}
