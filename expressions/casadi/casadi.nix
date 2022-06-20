{
  stdenv
  , lib
  , python
  , fetchFromGitHub
  , cmake
  , lapack
  , blas
  , swig
  , tinyxml
  , sundials
  , ipopt
  , pkg-config
  , mumps
}:

stdenv.mkDerivation rec {
  version = "3.5.5";
  pname = "casadi";

  src = fetchFromGitHub {
    owner = "casadi";
    repo = pname;
    rev = "402fe583f0d3cf1fc77d1e1ac933f75d86083124";
    sha256 = "sha256-gzfVwMPLs34Y5ftXaiTYjfgCtsoyULj13FU/SLjPpUI=";
    fetchSubmodules = true;
  };

  # HACK so python casadi python interface can find it's own libraries without
  # mucking about with any env vars or other options
  prePatch = ''
    substituteInPlace casadi/core/plugin_interface.hpp \
      --replace \
        "std::vector<std::string> search_paths;" \
        "std::vector<std::string> search_paths{ \"${placeholder "out"}/lib\" };"
  '';

  patches = [ ./pypi-meta.patch ];

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    lapack
    blas
    swig
    tinyxml
    sundials
    ipopt
    mumps
  ];

  cmakeFlags = [
    "-DPYTHON_PREFIX=${placeholder "out"}/${python.sitePackages}"
    "-DLIB_PREFIX=${placeholder "out"}/lib"
    "-DBIN_PREFIX=${placeholder "out"}/bin"
    "-DINCLUDE_PREFIX=${placeholder "out"}/include"
    "-DCASADI_PYTHON_PIP_METADATA_INSTALL=ON"
    "-DWITH_PYTHON=ON"
    "-DWITH_PYTHON3=ON"
    "-DPYTHON_EXECUTABLE=${python}/bin/python"
    "-DWITH_LAPACK=ON"
    "-DWITH_SUNDIALS=ON"
    "-DWITH_TINYXML=ON"
    "-DWITH_MUMPS=ON"
    "-DWITH_CLANG=OFF"
    "-DWITH_COMMON=ON"
  ];

  meta = with lib; {
    description = "Symbolic framework for automatic differentiation and numeric optimization.";
    homepage = "https://github.com/casadi/casadi";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}

