{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , src
  , clang
  , pybind11
  , joblib
  , toml
  , cmake
  , ninja
  , click
  , cymbal
  , jinja2
  , logzero
  , pandas
  , pathpy
  , pyparsing
  , schema
  , tqdm
  , toposort
  , llvmPackages
  , gcc
  , libglvnd
  , xlibs
  , python
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
    gcc
  ];

  dontUseCmakeConfigure = true;

  patches = [
    ./less-warnings.patch
  ];

  # do I need this at all?
  postPatch = ''
    substituteInPlace bindgen/CMakeLists.j2 --replace '$ENV{CONDA_PREFIX}/bin/python' ${python}
    substituteInPlace setup.py --replace "'path'" "'path.py'"
  '';

  pythonImportCheck = [ "bindgen" ];

  makeWrapperArgs = [
    ''--add-flags "-l ${llvmPackages.libclang}/lib/libclang.so"''
  ];

  meta = with lib; {
    description = "C++ binding generator based on libclang and pybind11";
    homepage = "https://github.com/CadQuery/pywrap/";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
