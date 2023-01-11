{ lib
, lapack
, openblas
, cmake
, stdenv
, pkgconfig
, python
, fetchFromGitHub
, fetchpatch
, swig
, ipopt
, osqp
, mumps
, scotch
, metis
}:

let
  ipopt-with-mumps = ipopt.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [
      "--with-mumps-cflags='-I${mumps}/include'"
    ];

    preConfigure = ''
      configureFlagsArray+=("--with-mumps-lflags='-L${mumps}/lib -ldmumps -lmumps_common -lmpiseq -lpord -L${scotch}/lib -lesmumps -lscotch -lscotcherr -L${metis}/lib -lmetis'")
    '';
  });
in
stdenv.mkDerivation rec {
  pname = "casadi";
  version = "3.5.5";

  src = fetchFromGitHub {
    owner = "casadi";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-7PK+153S9qerdtSMNvp3lWkmS2i3PlI/kjCTEAaWtao=";
    fetchSubmodules = true;
  };

  patches = [
   (fetchpatch {
    url = "https://raw.githubusercontent.com/conda-forge/casadi-feedstock/cdafbcd533cd64e0453e5ac9489f4acc4d53ed1e/recipe/2878.patch";
    sha256 = "sha256-kt0CyosfjPI8UvxCcJZLl5FluDSfJ6CcgsDQ8HeiwoI=";
   })
  ];

  nativeBuildInputs = [
    cmake
    pkgconfig
    swig
  ];

  buildInputs = [
    python

    osqp
    ipopt-with-mumps
    lapack
    openblas
    mumps
  ];

  # match the flags used in conda, with the addition of MUMPS support for
  # cadquery.
  cmakeFlags = [
   "-DWITH_PYTHON=ON"
   "-DWITH_PYTHON3=ON"
   "-DWITH_LAPACK=ON"
   "-DWITH_IPOPT=ON"
   "-DWITH_JSON=ON"
   "-DWITH_THREAD=ON"
   "-DWITH_OSQP=ON"
   "-DWITH_QPOASES=ON"
   "-DWITH_MUMPS=ON"
   "-DCASADI_PYTHON_PIP_METADATA_INSTALL=ON"
  ];

  # define the MUMPS env var so FindMUMPS.cmake can find it
  MUMPS = "${mumps}";

  preConfigure = ''
    # need to do this in the build itself because $out cannot be expanded in
    # cmakeFlags above
    cmakeFlags="$cmakeFlags -DPYTHON_PREFIX=$out/${python.sitePackages}/"
  '';

  # XXX: this is an extremely stupid hack to work around Casadi not knowing
  # to search the nix lib paths and it being annoying to patch the defaults
  postFixup = let
    rpath = lib.makeLibraryPath [
      stdenv.cc.cc.lib
      ipopt-with-mumps
    ];
  in ''
    new_rpath="${rpath}:$out/${python.sitePackages}/casadi:$out/lib"
    find $out/lib -name 'lib*.so*' -type f | while read lib; do
      patchelf --set-rpath $new_rpath $lib
    done
    patchelf --set-rpath $new_rpath \
        $out/${python.sitePackages}/casadi/_casadi.so
  '';

  doCheck = false;

  meta = with lib; {
    description = "Tool for nonlinear optimization and algorithmic differentiation.";
    homepage = "https://web.casadi.org/";
    license = licenses.lgpl3;
    maintainers = teams.determinatesystems.members;
  };
}
