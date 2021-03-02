{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , python
  , llvmPackages_6
  , writeTextFile
  , setuptools
}:
let 
  setuppy = writeTextFile {
    name = "setup.py";
    text = ''
      from setuptools import setup, find_packages
      from os import getenv


      setup(
          name="clang",
          version=getenv("version"),
          description="Python bindings to clang",
          license="ncsa",
          packages=find_packages(),
          test_suite="tests",
      )
    '';};
  src = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    rev = "llvmorg-6.0.1";
    sha256 = "sha256-L/Q9XS+RkjhA+61QxQ2dTSzOS9Z+5aEGnAj8skw6Jk4=";
  };

in buildPythonPackage {
  pname = "clang";
  version = "6.0.1";

  unpackPhase = ''
    export sourceRoot=$PWD/source
    mkdir $sourceRoot
    cp -rv --no-preserve=mode ${src}/clang/bindings/python/* $sourceRoot/
    cp -rv ${setuppy} $sourceRoot/setup.py
  '';

  propagatedBuildInputs = [
  #   llvmPackages_6.clang
    llvmPackages_6.clang-unwrapped.lib
  ];

  # makeWrapperArgs = [
  #   "--set CLANG_LIBRARY_PATH ${llvmPackages_6.clang-unwrapped.lib}/lib"
  # ];

  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${llvmPackages_6.clang-unwrapped.lib}/lib
  '';

  meta = with lib; {
    description = "Clang python bindings taken from the official distribution";
    homepage = "https://github.com/llvm/llvm-project";
    license = [ licenses.ncsa ];
    maintainers = [ maintainers.marcus7070 ];
  };
}
