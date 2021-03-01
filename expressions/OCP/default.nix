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
  , llvmPackages_9
  , libcxx
  , gcc9
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
  , debug ? true
  , pywrap
}:
let

  conda-like-libs = symlinkJoin {
    name = "OCP-conda-like-libs";
    paths = [
      opencascade-occt
      llvmPackages_9.libclang
    ];
  };

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

    CONDA_PREFIX = "${conda-like-libs}";

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

    patches = [
      ./py-fix.patch
      # note the order of the include paths in this patch are important, build
      # will fail if they are out of order
      ./includes.patch
      ./less-warnings.patch
    ];

    postPatch = ''
      substituteInPlace pywrap/bindgen/CMakeLists.j2 \
      --subst-var-by "python" "${python}"
      substituteInPlace pywrap/bindgen/utils.py \
      --subst-var-by "features_h" "${glibc.dev}/include" \
      --subst-var-by "limits_h" "${gcc9.cc}/lib/gcc/x86_64-unknown-linux-gnu/9.3.0/include-fixed" \
      --subst-var-by "type_traits" "${libcxx}/include/c++/v1" \
      --subst-var-by "stddef_h" "${gcc9.cc}/lib/gcc/x86_64-unknown-linux-gnu/9.3.0/include" \
      --subst-var-by "gldev" "${libglvnd.dev}" \
      --subst-var-by "libx11dev" "${xlibs.libX11.dev}" \
      --subst-var-by "xorgproto" "${xlibs.xorgproto}"
    '';

    preBuild = ''
      export PYBIND11_USE_CMAKE=1
      export PYTHONPATH=$PYTHONPATH:$(pwd)/pywrap 
    '';

    buildPhase = ''
      runHook preBuild
      echo "starting bindgen parse"
      python -m bindgen -n $NIX_BUILD_CORES parse ocp.toml out.pkl && \
      echo "finished bindgen parse" && \
      echo "starting transform" && \
      python -m bindgen -n $NIX_BUILD_CORES transform ocp.toml out.pkl out_f.pkl && \
      echo "finished bindgen transform" && \
      echo "starting generate" && \
      python -m bindgen -n $NIX_BUILD_CORES generate ocp.toml out_f.pkl && \
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
    separateDebugInfo = debug;

    disabled = pythonOlder "3.6" || pythonAtLeast "3.9";
    
    CONDA_PREFIX = "${conda-like-libs}";

    # phases = [ "unpackPhase" "patchPhase" "buildPhase" ];

    nativeBuildInputs = [
      cmake
      ninja
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
      gcc9.cc
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

  outputs = [ "out" ] ++ lib.lists.optional debug "debug";
  dontStrip = debug;

  postInstall = lib.strings.optionalString debug ''
    mkdir $debug
    cp -rv ${ocp-result.debug}/* $debug/
  '';

  pythonImportsCheck = [ "OCP" "OCP.gp" ];

  meta = with lib; {
    description = "Python wrapper for Opencascade Technology 7.4 generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
