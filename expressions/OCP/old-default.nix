{ lib
  , stdenv
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
  , gcc8
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
  , gcc-unwrapped
}:
let
  conda-like-libs = symlinkJoin {
    name = "OCP-conda-like-libs";
    paths = [
      opencascade-occt
      llvmPackages_9.libclang
    ];
  };
  # includes = symlinkJoin {
  #   name = "OCP-includes";
  #   paths = [
  #     (glibc.dev + "/include")
  #     libglvnd.dev
  #     xlibs.libX11.dev
  #     xlibs.xorgproto
  #     (llvmPackages_9.clang-unwrapped + "/lib/clang/9.0.1")
  #     (gcc-unwrapped + "/include")
  #     (llvmPackages_9.libcxx + "/include/c++/v1/")
  #   ];
  # };
# in llvmPackages_9.libcxxStdenv.mkDerivation rec {
# n llvmPackages_9.stdenv.mkDerivation rec {
in stdenv.mkDerivation rec {
  pname = "ocp";
  version = "7.4-RC1";

  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = pname;
    rev = version;
    sha256 = "04qh9fdbs5bay0zrhb5qm512g06h3rb9rhh4dma8xv5hxybf68di";
    fetchSubmodules = true;
  };

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
    # llvmPackages_9.libcxx
    libcxx
    # llvmPackages_9.clang-unwrapped
    # gcc8.cc
    glibc
    glibc.dev
  ];
  
  patches = [
    ./py-fix.patch
    # note the order of the include paths in this patch are important, build
    # will fail if they are out of order
    ./includes.patch
  ];

  postPatch = ''
    substituteInPlace pywrap/bindgen/CMakeLists.j2 \
    --subst-var-by "python" "${python}"
    substituteInPlace pywrap/bindgen/utils.py \
    --subst-var-by "features_h" "${glibc.dev}/include" \
    --subst-var-by "limits_h" "${gcc8.cc}/lib/gcc/x86_64-unknown-linux-gnu/8.4.0/include-fixed" \
    --subst-var-by "type_traits" "${libcxx}/include/c++/v1" \
    --subst-var-by "stddef_h" "${gcc8.cc}/lib/gcc/x86_64-unknown-linux-gnu/8.4.0/include" \
    --subst-var-by "gldev" "${libglvnd.dev}" \
    --subst-var-by "libx11dev" "${xlibs.libX11.dev}" \
    --subst-var-by "xorgproto" "${xlibs.xorgproto}"
  '';
    # --subst-var-by "type_traits" "${llvmPackages_9.libcxx}/include/c++/v1" \
    # --subst-var-by "stddef_h" "${llvmPackages_9.clang-unwrapped}/lib/clang/9.0.1/include" \

    # --subst-var-by "clang-includes" "${includes}"
    # --subst-var-by "clang-includes" "${llvmPackages_9.clang-unwrapped}/lib/clang/9.0.1/include/" \

  buildInputs = [
    opencascade-occt
    libglvnd.dev
    xlibs.libX11.dev
    xlibs.xorgproto
    glibc
    glibc.dev
    # llvm_9
    gcc8.cc
  ]; 

  # probably need OCCT in that cmake prefix as well
  preConfigure = ''
    export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
    export PYBIND11_USE_CMAKE=1
    export PYTHONPATH=$PYTHONPATH:$(pwd)/pywrap 
    # export CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:$(pwd)/opencascade
    echo "starting bindgen parse"
    python -m bindgen -n $NIX_BUILD_CORES parse ocp.toml out.pkl && \
    echo "finished bindgen parse, starting transform" && \
    python -m bindgen -n $NIX_BUILD_CORES transform ocp.toml out.pkl out_f.pkl && \
    echo "finished bindgen transform, starting generate" && \
    python -m bindgen -n $NIX_BUILD_CORES generate ocp.toml out_f.pkl
    echo "finished bindgen generate"
    echo "current directory is $(pwd)"
    cd OCP
    echo "current directory is $(pwd)"
    # cmake -B build -S "../OCP" -G Ninja -DCMAKE_BUILD_TYPE=Release
    # cmake --build build -- -k 0
  '';

  propagatedBuildInputs = [
  ];

  # cmakeFlags = [
  #   "-S ."
  # ];

  installPhase = ''
    # mkdir -p $out
    # cp out*.pkl $out
  '';

  checkInputs = [
  ];

  meta = with lib; {
    description = "Python wrapper for Opencascade Technology 7.4 generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    # license = licenses.asl20;  # not yet set
    maintainers = with maintainers; [ marcus7070 ];
  };
}
