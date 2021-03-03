{ 
  stdenv
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

  pythonImportCheck = [ "bindgen" ];

  makeWrapperArgs = [
    ''--add-flags "-l ${llvmPackages.libclang}"''
  ] ++ map (p: ''--add-flags "-i '' + p + ''"'') [
    "${stdenv.glibc.dev}/include"
    "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include-fixed"
    "${llvmPackages.libcxx}/include/c++/v1"
    "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include"
    libglvnd.dev
    xlibs.libX11.dev
    xlibs.xorgproto
  ];

  meta = with stdenv.lib; {
    description = "C++ binding generator based on libclang and pybind11";
    homepage = "https://github.com/CadQuery/pywrap/";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
