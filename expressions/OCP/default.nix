{ lib
  , stdenv
  , src
  , buildPythonPackage
  , pythonOlder
  , cmake
  , ninja
  , glibc
  , opencascade-occt
  , llvmPackages
  , pybind11
  , libglvnd
  , xorg
  , python
  , writeTextFile
  , pywrap
  , vtk
  , rapidjson
  , lief
  , path
}:
let
  # We need to use an unmodified version number for the dist-utils version so
  # that the version check in cadquery works
  # remember to change version number in dump_symbols.py as well
  base-version = "7.7.2";
  version = "v${base-version}-git-${src.shortRev}";

  vtk_main_version = lib.versions.majorMinor vtk.version;

  ocp-dump-symbols = stdenv.mkDerivation rec {
    pname = "ocp-dump-symbols";
    inherit version src;

    nativeBuildInputs = [
      lief
      path
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
    pywrapFlags = 
    let
      system = stdenv.hostPlatform.system;
      compiler = if system == "x86_64-linux" then "x86_64-unknown-linux-gnu"
                 else if system == "aarch64-linux" then "aarch64-unknown-linux-gnu"
                 else (throw "unsupported system ${system}");

    in builtins.concatStringsSep " " (
      map (p: ''-i '' + p) [
        "${rapidjson}/include"
        "${vtk}/include/vtk/"
        "${xorg.xorgproto}/include"
        "${xorg.libX11.dev}/include"
        "${libglvnd.dev}/include"
        "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}"
        "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/${compiler}"
        "${glibc.dev}/include"
        "${stdenv.cc.cc}/lib/gcc/${compiler}/${stdenv.cc.version}/include-fixed"
        "${stdenv.cc.cc}/lib/gcc/${compiler}/${stdenv.cc.version}/include"
    ]);

    buildPhase = ''
      runHook preBuild
      pywrap -n $NIX_BUILD_CORES ${pywrapFlags} all ocp.toml
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
      xorg.libX11.dev
      xorg.xorgproto
      vtk
    ] ++ opencascade-occt.buildInputs ++ vtk.buildInputs;

    preConfigure = ''
      export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      export PYBIND11_USE_CMAKE=1
      export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${glibc.dev}/include
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
      "-DOpenCASCADE_INCLUDE_DIR=${src}/opencascade"
      "-DVTK_DIR=${vtk}/lib/cmake/vtk/"
      "-Wno-dev"
    ];

    seperateDebugInfo = true;

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
          version=getenv("SETUPTOOLS_SCM_PRETEND_VERSION"),
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

  SETUPTOOLS_SCM_PRETEND_VERSION="${base-version}";

  prePatch = ''
    cp ${setuppy} ./setup.py
  '';

  propagatedBuildInputs = [ opencascade-occt ];

  pythonImportsCheck = [ "OCP" "OCP.gp" ];

  meta = with lib; {
    description = "Python wrapper for Opencascade Technology ${version} generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
