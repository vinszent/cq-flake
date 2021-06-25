{ lib
  , stdenv
  , src
  , buildPythonPackage
  , pythonOlder
  , cmake
  , ninja
  , opencascade-occt
  , llvmPackages
  , pybind11
  , libglvnd
  , xlibs
  , python
  , writeTextFile
  , pywrap
  , vtk_9
  , rapidjson
  , lief
  , pathpy
}:
let

  version = "v7.5.1-git-" + src.shortRev;

  ocp-dump-symbols = stdenv.mkDerivation rec {
    pname = "ocp-dump-symbols";
    inherit version src;

    nativeBuildInputs = [
      lief
      pathpy
      opencascade-occt
    ];

    phases = [
      "unpackPhase"
      "buildPhase"
      "installPhase"
      "installCheckPhase"
    ];

    dumpSymbols = ./dump_symbols.py;

    buildPhase = ''
      python $dumpSymbols ${opencascade-occt}
    '';

    installPhase = ''
      mkdir -p $out
      cp ./symbols_mangled_linux.dat $out
      echo "Checking we did not install an empty file"
      [ -s $out/symbols_mangled_linux.dat ]
    '';

  };


  # intermediate step, do pybind, cmake in the next step
  ocp-pybound = stdenv.mkDerivation rec {
    pname = "pybound-ocp";
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
      pywrap
      rapidjson
      ocp-dump-symbols
    ];

    postPatch = ''
      cp ${ocp-dump-symbols}/symbols_mangled_linux.dat ./
    '';

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
        "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}"
        "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu"
        "${stdenv.glibc.dev}/include"
        "${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.version}/include-fixed"
        "${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.version}/include"
    ]);

    buildPhase = ''
      runHook preBuild
      echo "pywrapFlags are: ${pywrapFlags}"
      echo "starting bindgen parse"
      pywrap -n $NIX_BUILD_CORES ${pywrapFlags} parse ocp.toml out.pkl && \
      echo "finished bindgen parse" && \
      echo "starting transform" && \
      pywrap -n $NIX_BUILD_CORES ${pywrapFlags} transform ocp.toml out.pkl out_f.pkl && \
      echo "finished bindgen transform" && \
      echo "starting generate" && \
      pywrap -n $NIX_BUILD_CORES ${pywrapFlags} generate ocp.toml out_f.pkl && \
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
    inherit version;

    src = ocp-pybound;

    disabled = pythonOlder "3.6";
    
    # do not put glibc.dev in here https://discourse.nixos.org/t/how-to-get-this-basic-c-build-to-work-in-a-nix-shell/12262/3
    # https://github.com/NixOS/nixpkgs/pull/28748
    nativeBuildInputs = [
      cmake
      ninja
      pywrap
      pybind11
      python
      rapidjson
    ];
    
    buildInputs = [
      libglvnd.dev
      xlibs.libX11.dev
      xlibs.xorgproto
      vtk_9
    ] ++ opencascade-occt.buildInputs ++ vtk_9.buildInputs;

    preConfigure = ''
      export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      export PYBIND11_USE_CMAKE=1
      export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${stdenv.glibc.dev}/include
      echo "CMAKE_INCLUDE_PATH is:"
      echo $CMAKE_INCLUDE_PATH
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-deprecated-declarations"
      echo "NIX_CFLAGS_COMPILE: $NIX_CFLAGS_COMPILE"
    '';

    # I don't think I need this, but keep it here incase I notice multithread problems later:
    # NIX_CFLAGS_LINK = "-lpthread -ldl";

    propagatedBuildInputs = [
      opencascade-occt
    ];

    cmakeFlags = [
      "-S ../OCP"
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
      "-DOPENCASCADE_INCLUDE_DIR=${src}/opencascade"
      "-DCMAKE_CXX_STANDARD_LIBRARIES=${vtk_9}/lib/libvtkWrappingPythonCore-9.0.so"
      # "-DCMAKE_CXX_FLAGS='"-I\ ${vtk_9}/include/vtk-9.0'""
      "-DVTK_DIR=${vtk_9}/lib/cmake/vtk-9.0/"
      "-Wno-dev"
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

  # the old hardcoded output name was:
  #         package_data={
  #             "": ["OCP.cpython-38-x86_64-linux-gnu.so"]
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
              "": ["OCP.${python.implementation}-${python.sourceVersion.major}${python.sourceVersion.minor}-${stdenv.system}-gnu.so"]
          },
          cmdclass = {"build_py": BuildPyNoBuild}
      )
    '';
  };
    
in buildPythonPackage {
  pname = "OCP";
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
