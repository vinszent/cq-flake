{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , cadquery
  , pytestCheckHook
  , rich
}:
buildPythonPackage rec {
  pname = "cq-kit";
  rev = "ad1e12b919911f1145262d85adf329995f2ed59e";
  version = "0.5.8";
  src = fetchFromGitHub {
    owner = "michaelgale";
    repo = pname;
    inherit rev;
    sha256 = "sha256-opk2eESaZoel9Oc8UYi7DsDnMJf623twQ77DHHLzfHo=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [ cadquery ];

  checkInputs = [ pytestCheckHook rich ];
}
