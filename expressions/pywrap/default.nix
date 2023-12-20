{
  lib
  , buildPythonPackage
  , pythonOlder
  , src
  , clang
  , pybind11
  , joblib
  , toml
  , cmake
  , ninja
  , click
  , jinja2
  , logzero
  , pandas
  , path
  , pyparsing
  , schema
  , tqdm
  , toposort
  , llvmPackages
  , python
  , fetchpatch
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
    jinja2
    logzero
    pandas
    path
    pyparsing
    schema
    tqdm
    toposort
    llvmPackages.libclang
  ];

  dontUseCmakeConfigure = true;

  patches = [
    ./less-warnings.patch
    ./new-pandas-read-csv.patch
    # ./003_log_dropped_methods.patch
  ];

  # do I need this at all?
  postPatch = ''
    substituteInPlace bindgen/CMakeLists.j2 --replace '$ENV{CONDA_PREFIX}/bin/python' ${python}
  '';

  pythonImportCheck = [ "bindgen" ];

  makeWrapperArgs = [
    ''--add-flags "-l ${llvmPackages.libclang.lib}/lib/libclang.so"''
  ];

  meta = with lib; {
    description = "C++ binding generator based on libclang and pybind11";
    homepage = "https://github.com/CadQuery/pywrap/";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
