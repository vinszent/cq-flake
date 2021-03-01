{ 
  stdenv
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , src
}:

buildPythonPackage rec {
  version = "git-" + builtins.substring 0 7 src.rev;
  pname = "pywrap";
  inherit src;

  propagatedBuildInputs = [
    clang
    pybind11
    joblib
    toml
    cmake
    ninja
    click
    cymbal
    jinja2
    logzero
    pandas
    pathpy
    pyparsing
    schema
    tqdm
    toposort
  ];

  meta = with stdenv.lib; {
    description = "C++ binding generator based on libclang and pybind11";
    homepage = "https://github.com/CadQuery/pywrap/";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
