{
  stdenv
  , lib
  , fetchFromGitHub
  , blas
  , lapack
  , scotch
  , metis
  , gfortran
}:

stdenv.mkDerivation rec {
  version = "5.1.1";
  pname = "mumps";

  src = fetchFromGitHub {
    owner = "cfwen";
    repo = pname;
    rev = "30808bd0b92ab2ea507e2a3e41469b27c2b1dda3";
    sha256 = "sha256-LtqFJTE8sjTZ7F/44ETWRQW95ha4hAh+5RQEoA7jKrw=";
  };

  makeFlags = [
    "alllib"
    "requiredobj"
  ];

  # Create custom makefile. Which uses a hack to disable arg mismatch for fortran
  # since the codebase is full of these errors.
  prePatch = ''
    mkdir -p  lib
    cp Make.inc/Makefile.debian.SEQ ./Makefile.inc
    substituteInPlace ./Makefile.inc \
      --replace "LSCOTCHDIR = /usr/lib" "LSCOTCHDIR = ${scotch}/lib" \
      --replace "ISCOTCH   = -I/usr/include/scotch" "ISCOTCH   = -I${scotch}/include" \
      --replace "LMETISDIR = /usr/lib" "LMETISDIR = ${metis}/lib" \
      --replace "IMETIS    = -I/usr/include/metis" "IMETIS    = -I${metis}/include" \
      --replace "OPTF    = -O # -fopenmp" "OPTF    = -fallow-argument-mismatch -O # -fopenmp"
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/include/mumps_seq
    cp -r ./lib/* $out/lib
    cp -r ./include/* $out/include
    cp -r ./libseq/*.h $out/include/mumps_seq
    cp -r ./libseq/libmpiseq.a $out/lib
  '';

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    blas
    lapack
    scotch
    metis
  ];

  meta = with lib; {
    description = "MUMPS: a parallel sparse direct solver";
    homepage = "http://mumps-solver.org/";
    maintainers = with maintainers; [ ];
  };
}

