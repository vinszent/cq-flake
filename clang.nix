{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , python
  , llvmPackages_9
}:

buildPythonPackage {
  pname = "clang";
  version = "9.0.1";
  src = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    rev = "llvmorg-9.0.1";
    sha256 = "1d1qayvrvvc1di7s7jfxnjvxq2az4lwq1sw1b2gq2ic0nksvajz0";
  };

  format = "other";
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  propagatedBuildInputs = [ llvmPackages_9.clang ];

  installPhase = ''
    install -D --target-directory=$out/${python.sitePackages}/clang ./clang/bindings/python/clang/*
  '';

  meta = with lib; {
    description = "Clang python bindings taken from the official distribution";
    homepage = "https://github.com/llvm/llvm-project";
    license = [ licenses.ncsa ];
    maintainers = [ maintainers.marcus7070 ];
  };
}
