# Based on bitrotted PR https://github.com/NixOS/nixpkgs/pull/55358/
# This builds the MUMPS static libraries in "seq" mode (no MPI support) in the
# format expected by casadi.
{ lib
, stdenv
, fetchurl
, openblas
, liblapack
, scalapack
, metis
, scotch
, gfortran
, openmpi
}:

stdenv.mkDerivation rec {
  pname = "mumps";
  version = "5.2.1";

  src = fetchurl {
    url = "http://graal.ens-lyon.fr/MUMPS/MUMPS_${version}.tar.gz";
    sha256 = "d988fc34dfc8f5eee0533e361052a972aa69cc39ab193e7f987178d24981744a";
  };

  patchPhase = ''
    ln -s Make.inc/Makefile.debian.SEQ Makefile.inc
    substituteInPlace Makefile.inc \
      --replace "LSCOTCHDIR = /usr/lib" "LSCOTCHDIR = ${scotch}/lib" \
      --replace "ISCOTCH   = -I/usr/include/scotch" "ISCOTCH   = -I${scotch}/include" \
      --replace "LMETISDIR = /usr/lib" "LMETISDIR = ${metis}/lib" \
      --replace "IMETIS    = -I/usr/include/metis" "IMETIS    = -I${metis}/include" \
      --replace "INCPAR = -I/usr/lib/openmpi/include" "INCPAR = -I${openmpi}/include" \
      --replace 'LIBPAR = $(SCALAP) $(LAPACK)  -lmpi -lmpi_f77' 'LIBPAR = $(SCALAP) $(LAPACK) -lmpi -lmpi_mpifh' \
      --replace "SCALAP  = -lscalapack-openmpi" "SCALAP  = -lscalapack" \
      --replace "FC = mpif90" "FC = mpif90 -fallow-argument-mismatch" \
      --replace "FC = gfortran" "FC = gfortran -fallow-argument-mismatch"
  '';

  buildInputs = [ gfortran openblas liblapack metis openmpi scalapack scotch ];

  buildFlags = [ "all" ];

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/include/mumps_seq
    install include/* $out/include/
    install libseq/*.h $out/include/mumps_seq
    install libseq/*.h $out/include
    install lib/*.a $out/lib
    install libseq/*.a $out/lib
  '';

  meta = {
    description = "A parallel sparse direct solver";
    homepage = "http://mumps-solver.org/";
    license = lib.licenses.cecill-c;
    platforms = lib.platforms.all;
    maintainers = [];
  };
}
