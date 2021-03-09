{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , python
  , llvmPackages
  , writeTextFile
  , setuptools
  , src
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

in buildPythonPackage {
  pname = "clang";
  version = llvmPackages.clang-unwrapped.version;

  unpackPhase = ''
    export sourceRoot=$PWD/source
    mkdir $sourceRoot
    cp -rv --no-preserve=mode ${src}/clang/bindings/python/* $sourceRoot/
    cp -rv ${setuppy} $sourceRoot/setup.py
  '';

  propagatedBuildInputs = [
    llvmPackages.clang-unwrapped.lib
  ];

  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${llvmPackages.clang-unwrapped.lib}/lib
  '';

  meta = with lib; {
    description = "Clang python bindings taken from the official distribution";
    homepage = "https://github.com/llvm/llvm-project";
    license = [ licenses.ncsa ];
    maintainers = [ maintainers.marcus7070 ];
  };
}
