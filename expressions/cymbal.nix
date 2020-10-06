{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , unittest2
  , clang
}:
buildPythonPackage rec {
  pname = "cymbal";
  version = "git-2016";
  src = fetchFromGitHub {
    owner = "AndrewWalker";
    repo = pname;
    rev = "f0c7e7dfff1b4fd4ef4326c52f41a8ffb9d62c0c";
    sha256 = "1zfbszyd6pxi90slh289fl83h8rkd99c4x3gf70mzmjw8cks4f9y";
  };

  propagatedBuildInputs = [ clang ];

  checkInputs = [ unittest2 ];
  doCheck = false;
}
