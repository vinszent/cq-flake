{ lib
  , stdenv
  , clangStdenv
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
  , freetype
  , python
  , writeTextFile
  , pywrap
  , utf8cpp
  , rapidjson
  , nlohmann_json
  , lief
  , path
  , setuptools

  , vtk
  , tbb_2021
  , fontconfig
}:
let
  # We need to use an unmodified version number for the dist-utils version so
  # that the version check in cadquery works
  # remember to change version number in dump_symbols.py as well
  base-version = "7.8.1.2";
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
  # llvmPackages.stdenv
  ocp-pybound = llvmPackages.stdenv.mkDerivation rec {
    pname = "pybound-ocp";
    inherit version src;

    /*
    phases = [
      "unpackPhase"
      "patchPhase"
      "buildPhase"
      "installPhase"
    ];*/

    nativeBuildInputs = [
      # cmake
      pywrap
      rapidjson
      nlohmann_json
      ocp-dump-symbols
    ] ++ (with llvmPackages; [
      libllvm
      libclang
    ]);

    buildInputs = [
      freetype
      libglvnd
      llvmPackages.openmp
      tbb_2021
      utf8cpp
      xorg.xorgproto
      xorg.libX11
    ];

    dontWrapQtApps = true;

    postPatch = ''
      cp ${ocp-dump-symbols}/symbols_mangled_linux.dat ./
      substituteInPlace CMakeLists.txt \
        --replace-fail "\''${CMAKE_SOURCE_DIR}/pywrap" \
        "${python.pkgs.makePythonPath [ pywrap ]}" \
        --replace-fail "\''${VTK_INCLUDE_DIR}" \
        "${vtk}/include/vtk" \
        --replace-fail "\''${N_PROC}" \
        "\$ENV{NIX_BUILD_CORES}" \
        --replace-fail "\''${CLANG_INSTALL_PREFIX}" \
        "${llvmPackages.libclang.lib}" \
        --replace-fail "add_subdirectory( \''${CMAKE_SOURCE_DIR}/OCP )" \
        ""
    '';
    # env.PYBIND11_USE_CMAKE = 1;

    cmakeFlags = with llvmPackages; [
      "-GNinja"
      "-DVTK_DIR=${vtk}/lib/cmake/vtk"
      "-DOpenCASCADE_DIR=${opencascade-occt}/lib/cmake/opencascade"
      "-Dpybind11_DIR=${pybind11}/share/cmake/pybind11"

      "-DCMAKE_C_COMPILER=${clang}/bin/clang"
      "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
    ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cd ..
      cp -r ./OCP/* $out/
    '';
  };

  # llvmPackages.stdenv
  ocp-result = llvmPackages.stdenv.mkDerivation rec {
    pname = "ocp-result";
    inherit version;

    src = ocp-pybound;

    disabled = pythonOlder "3.6";

    # env.NIX_DEBUG = "1";

    # do not put glibc.dev in here https://discourse.nixos.org/t/how-to-get-this-basic-c-build-to-work-in-a-nix-shell/12262/3
    # https://github.com/NixOS/nixpkgs/pull/28748
    nativeBuildInputs = [
      cmake
      ninja
      pywrap
      pybind11
      python
    ] /*++ (with llvmPackages; [
      libllvm
      libclang
    ])*/;

    buildInputs = [
      rapidjson
      libglvnd.dev
      xorg.libX11.dev
      xorg.xorgproto
      vtk
      tbb_2021

      # > The link interface of target "VTK::CommonCore" contains:
      # >
      # > OpenMP::OpenMP_CXX
      llvmPackages.openmp
      fontconfig
    ];

    /*
    postPatch = ''
      substituteInPlace OCP/CMakeLists.txt \
        --replace-fail \
        "include_directories( \''${PROJECT_SOURCE_DIR}" \
        "include_directories( \''${PROJECT_SOURCE_DIR} \''${OpenCASCADE_VENDORED_INCLUDE_DIR}"
    '';*/

    env = {
      PYBIND11_USE_CMAKE = 1;
      CMAKE_PREFIX_PATH = "${pybind11}/share/cmake/pybind11:\${CMAKE_PREFIX_PATH}:${glibc.dev}/include";
      NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations";
    };

    preConfigure = ''
      echo "CMAKE_INCLUDE_PATH is:"
      echo $CMAKE_INCLUDE_PATH
      echo "NIX_CFLAGS_COMPILE: $NIX_CFLAGS_COMPILE"
    '';

    # I don't think I need this, but keep it here incase I notice multithread problems later:
    # NIX_CFLAGS_LINK = "-lpthread -ldl";

    propagatedBuildInputs = [
      opencascade-occt
    ];

    cmakeFlags = with llvmPackages; [
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
      "-DVTK_DIR=${vtk}/lib/cmake/vtk/"
      # "-DOpenCASCADE_VENDORED_INCLUDE_DIR=${src}/opencascade"
      "-Wno-dev"

      /*
      "-DCMAKE_C_COMPILER=${clang}/bin/clang"
      "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"*/
    ];

    separateDebugInfo = true;
    # vtk uses qtbase so we're forced to specify wrapping behavior
    dontWrapQtApps = true;

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
  pyproject = true;
  build-system = [ setuptools ];

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
