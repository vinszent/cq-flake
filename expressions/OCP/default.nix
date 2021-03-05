{ lib
  , stdenv
  , src
  , buildPythonPackage
  , symlinkJoin
  , fetchFromGitHub
  , pythonOlder
  , pythonAtLeast
  , cmake
  , ninja
  , opencascade-occt
  , toml
  , logzero
  , pandas
  , joblib
  , pathpy
  , tqdm
  , jinja2
  , toposort
  , llvmPackages
  , libcxx
  , gcc
  , clang
  , pyparsing
  , pybind11
  , cymbal
  , schema
  , click
  , llvm_9
  , glibc
  , libglvnd
  , xlibs
  , python
  , writeTextFile
  , pywrap
}:
let

  # conda-like-libs = symlinkJoin {
  #   name = "OCP-conda-like-libs";
  #   paths = [
  #     opencascade-occt
  #     llvmPackages_9.libclang
  #   ];
  # };

  # intermediate step, do pybind, cmake in the next step
  ocp-pybound = stdenv.mkDerivation rec {
    pname = "pybound-ocp";
    version = "git-" + builtins.substring 0 7 src.rev;
    inherit src;

    phases = [
      "unpackPhase"
      "patchPhase"
      "buildPhase"
      "installPhase"
    ];

    # CONDA_PREFIX = "${conda-like-libs}";

    nativeBuildInputs = [
      toml
      clang # the python package
      logzero
      pandas
      joblib
      pathpy
      tqdm
      jinja2
      toposort
      pyparsing
      pybind11
      cymbal
      schema
      click
      libcxx
      glibc
      glibc.dev
      pywrap
    ];

    preBuild = ''
      # should this actually be in pywrap?
      export PYBIND11_USE_CMAKE=1
    '';

  # the order of the following includes is critical, but makes utterly zero sense to me. Order discovered by trial and error and anger.
    pywrapFlags =  builtins.concatStringsSep " " (
      map (p: ''-i '' + p) [
        "${xlibs.xorgproto}/include"
        "${xlibs.libX11.dev}/include"
        "${libglvnd.dev}/include"
        "${llvmPackages.libcxx}/include/c++/v1"
        "${stdenv.glibc.dev}/include"
        "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include-fixed"
        "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include"
        # "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include"
        # "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include-fixed"
        # "${stdenv.glibc.dev}/include"
        # "${llvmPackages.libcxx}/include/c++/v1"
        # "${libglvnd.dev}/include"
        # "${xlibs.libX11.dev}/include"
        # "${xlibs.xorgproto}/include"
    ]);

    buildPhase = ''
      runHook preBuild
      echo "pywrapFlags are:"
      echo $pywrapFlags
      echo "starting bindgen parse"
      # python -m bindgen -n $NIX_BUILD_CORES parse ocp.toml out.pkl && \
      pywrap -n $NIX_BUILD_CORES $pywrapFlags parse ocp.toml out.pkl && \
      echo "finished bindgen parse" && \
      echo "starting transform" && \
      # python -m bindgen -n $NIX_BUILD_CORES transform ocp.toml out.pkl out_f.pkl && \
      pywrap -n $NIX_BUILD_CORES $pywrapFlags transform ocp.toml out.pkl out_f.pkl && \
      echo "finished bindgen transform" && \
      echo "starting generate" && \
      # python -m bindgen -n $NIX_BUILD_CORES generate ocp.toml out_f.pkl && \
      pywrap -n $NIX_BUILD_CORES $pywrapFlags generate ocp.toml out_f.pkl && \
      echo "finished bindgen generate"
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
    '';
  };

  ocp-result = stdenv.mkDerivation rec {
    pname = "ocp-result";
    version = "7.4-RC1";

    src = ocp-pybound;

    disabled = pythonOlder "3.6";
    
    # CONDA_PREFIX = "${conda-like-libs}";

    # phases = [ "unpackPhase" "patchPhase" "buildPhase" ];

    nativeBuildInputs = [
      cmake
      ninja
      pywrap
      # python
      toml
      clang # the python package
      # llvm_9
      # llvmPackages_9.clang
      logzero
      pandas
      joblib
      pathpy
      tqdm
      jinja2
      toposort
      pyparsing
      pybind11
      cymbal
      schema
      click
      # glibc.dev
      # llvmPackages_9.libcxx
      libcxx
      # llvmPackages_9.clang-unwrapped
      # gcc8.cc
      # glibc
    ];
    
    buildInputs = [
      libglvnd.dev
      xlibs.libX11.dev
      xlibs.xorgproto
      # glibc
      # glibc.dev
      # llvm_9
      gcc.cc
    ]; 

    # probably need OCCT in that cmake prefix as well
    preConfigure = ''
      export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      export PYBIND11_USE_CMAKE=1
      cp -v ./*.pkl ./OCP/
    '';

    preBuild = ''
      # export CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:$(pwd)/opencascade
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-deprecated-declarations"
    '';

    propagatedBuildInputs = [
      opencascade-occt
    ];

    cmakeFlags = [
      "-S ../OCP"
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
      "-DOPENCASCADE_INCLUDE_DIR=${src}/opencascade"
    ];

    checkPhase = ''
      pushd .
      cd build
      python -c "import OCP.gp"
      popd
    '';

    installPhase = ''
      mkdir $out
      cp ./*.so $out/
    '';
    # installPhase = ''
    #   dest=$(toPythonPath $out)
    #   install -D --mode=0555 --target=$dest ./*.so
    # '';
      # install -D --target=$dest ${ocp-pybound}/*.pkl
      # echo "from .OCP import *" > $dest/__init__.py
  };
  setuppy = writeTextFile {
    name = "setup.py";
    text = ''
      from setuptools import setup
      from setuptools.command.build_py import build_py
      from os import getenv


      class BuildPyNoBuild(build_py):
          def build_packages(self):
              pass


      setup(
          name='OCP',
          version=getenv("version"),
          description="Python wrapper for OCCT",
          license="Apache License 2.0",
          packages=[""],
          package_dir={"": "."},
          package_data={
              "": ["OCP.cpython-38-x86_64-linux-gnu.so"]
          },
          cmdclass = {"build_py": BuildPyNoBuild}
      )
    '';
  };
    
in buildPythonPackage {
  pname = "OCP";
  version = "7.4-RC1";
  src = ocp-result;

  prePatch = ''
    cp ${setuppy} ./setup.py
  '';

  propagatedBuildInputs = [ opencascade-occt ];

  pythonImportsCheck = [ "OCP" "OCP.gp" ];

  meta = with lib; {
    description = "Python wrapper for Opencascade Technology 7.4 generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
