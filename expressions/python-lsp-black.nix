{ lib
, buildPythonPackage
, fetchFromGitHub
, black
, toml
, pytestCheckHook
, python-lsp-server
, isPy3k
}:

buildPythonPackage rec {
  pname = "python-lsp-black";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-black";
    rev = "v${version}";
    sha256 = "sha256-fDCHH+9C5dX6POdGGx9nTX8+04TdJyO5yt9hJ0kVYw4=";
  };

  disabled = !isPy3k;

  checkInputs = [ pytestCheckHook ];

  propagatedBuildInputs = [ black toml python-lsp-server ];

  meta = with lib; {
    homepage = "https://github.com/python-lsp/python-lsp-black";
    description = "python-lsp-server plugin that adds support to black autoformatter, forked from https://github.com/rupert/pyls-black/";
    license = licenses.mit;
    maintainers = [ ];
  };
}
