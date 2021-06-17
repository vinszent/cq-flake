{ lib
  , stdenv
  , src
  , buildPythonPackage
  , fetchFromGitHub
  , pythonOlder
  , cmake
  , ninja
  , opencascade-occt
  , llvmPackages
  , libcxx
  , gcc
  , pybind11
  # , glibc
  , libglvnd
  , xlibs
  , python
  , writeTextFile
  , pywrap
  , vtk_9
  , rapidjson
}:
let

  version = "v7.5.1-git-" + src.shortRev;

  # intermediate step, do pybind, cmake in the next step
  ocp-pybound = stdenv.mkDerivation rec {
    pname = "pybound-ocp";
    # version = "git-" + builtins.substring 0 7 src.rev;
    inherit version src;

    phases = [
      "unpackPhase"
      "patchPhase"
      "buildPhase"
      "installPhase"
    ];

    patches = [
      # ./000_just_BRepTools.patch
    ];

    nativeBuildInputs = [
      llvmPackages.libcxx
      pywrap
      rapidjson
    ];

    # should this actually be in pywrap?
    preBuild = ''
      export PYBIND11_USE_CMAKE=1
    '';

  # the order of the following includes is critical, but makes utterly zero sense to me. Order discovered by trial and error and hulk smashing the keyboard.
    pywrapFlags =  builtins.concatStringsSep " " (
      map (p: ''-i '' + p) [
        "${rapidjson}/include"
        "${vtk_9}/include/vtk-9.0/"
        "${xlibs.xorgproto}/include"
        "${xlibs.libX11.dev}/include"
        "${libglvnd.dev}/include"
        "${llvmPackages.libcxx}/include/c++/v1"
        "${stdenv.glibc.dev}/include"
        "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include-fixed"
        "${gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${gcc.version}/include"
    ]);

    buildPhase = ''
      runHook preBuild
      echo "pywrapFlags are:"
      echo $pywrapFlags
      echo "starting bindgen parse"
      pywrap -n $NIX_BUILD_CORES $pywrapFlags parse ocp.toml out.pkl && \
      echo "finished bindgen parse" && \
      echo "starting transform" && \
      pywrap -n $NIX_BUILD_CORES $pywrapFlags transform ocp.toml out.pkl out_f.pkl && \
      echo "finished bindgen transform" && \
      echo "starting generate" && \
      pywrap -n $NIX_BUILD_CORES $pywrapFlags generate ocp.toml out_f.pkl && \
      echo "finished bindgen generate"
      runHook postBuild
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
    '';
  };

  ocp-result = stdenv.mkDerivation rec {
    pname = "ocp-result";
    # version = "7.5.1-git-" + src.shortRev;
    inherit version;

    src = ocp-pybound;

    disabled = pythonOlder "3.6";
    
    nativeBuildInputs = [
      cmake
      ninja
      pywrap
      pybind11
      python
      libcxx
      rapidjson
    ];
    
    buildInputs = [
      libglvnd.dev
      xlibs.libX11.dev
      xlibs.xorgproto
      gcc.cc
      vtk_9
    ] ++ opencascade-occt.buildInputs ++ opencascade-occt.propagatedBuildInputs; 

    preConfigure = ''
      export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      export PYBIND11_USE_CMAKE=1
      cp -v ./*.pkl ./OCP/
    '';

    preBuild = ''
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-deprecated-declarations"
    '';

    propagatedBuildInputs = [
      opencascade-occt
    ];

    cmakeFlags = [
      "-S ../OCP"
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
      "-DOPENCASCADE_INCLUDE_DIR=${src}/opencascade"
      # "-DCMAKE_CXX_STANDARD_LIBRARIES=${vtk_9}/lib/libtkWrappingPythonCore-9.0.so.9.0.1"
      # "-DCMAKE_CXX_FLAGS=-I\ ${vtk_9}/include/vtk-9.0"
      # "-DVTK_DIR=${vtk_9}/lib/cmake/vtk-9.0/"
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
  };

  # TODO: get rid of hardcoded python version in the following:
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
  # version = lib.debug.traceSeqN 3 src.shortRev ("7.5.1-git-" + src.shortRev);
  inherit version;
  src = ocp-result;

  prePatch = ''
    cp ${setuppy} ./setup.py
  '';

  propagatedBuildInputs = [ opencascade-occt ];

  pythonImportsCheck = [ "OCP" "OCP.gp" ];

  meta = with lib; {
    description = "Python wrapper for Opencascade Technology 7.5.1 generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
