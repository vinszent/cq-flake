{ stdenv, lib, buildPythonPackage, fetchFromGitHub, pythonOlder,
  ujson, pylint, pycodestyle, pyflakes, pytestCheckHook, pytest-cov,
  coverage }:

buildPythonPackage rec {
  pname = "python-lsp-jsonrpc";
  version = "v1.0.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "python-lsp-jsonrpc";
    rev = version;
    sha256 = "sha256-ETQY9hGUK8NVPJi/9uEn2Q6s068qlS3ABZV1RTTSi0A=";
  };

  propagatedBuildInputs = [ ujson ];

  checkInputs = [ pytestCheckHook pylint pycodestyle pyflakes pytest-cov coverage ];

  meta = with lib; {
    description = "The uncompromising Python code formatter";
    homepage    = "https://github.com/psf/black";
    license     = licenses.mit;
    maintainers = with maintainers; [ sveitser ];
  };

}
