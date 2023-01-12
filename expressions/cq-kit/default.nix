{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , cadquery
  , pytestCheckHook
}:
buildPythonPackage rec {
  pname = "cq-kit";
  rev = "1c9883abab29f86798ff9b4dca28c5b19cfb852b";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "michaelgale";
    repo = pname;
    inherit rev;
    sha256 = "sha256-IkmwS2+OkvX8V8NtD2O4+kcRfU+YtPpWCMSymLFOlLE=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [ cadquery ];

  checkInputs = [ pytestCheckHook ];

  preCheck = ''
    pushd .
    cd tests
  '';

  postCheck = ''
    popd
  '';

}
