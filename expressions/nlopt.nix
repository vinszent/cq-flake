{ lib
  , stdenv
  , fetchFromGitHub
  , cmake
  , octave ? null
  , python
  , swig
  , numpy
  , buildPythonPackage
}:

buildPythonPackage rec {
  pname = "nlopt";
  version = "2.10.0dev";

  src = fetchFromGitHub {
    owner = "stevengj";
    repo = pname;
    rev = "a75f3d99785a3f99ecdf851c8f32718466907017"; # v${version}
    sha256 = "sha256-lUk1h2cRlvxox5zaJHd4iHagLr2EgIaXTkAJoXsnPok=";
  };

  format = "other";

  nativeBuildInputs = [
    cmake
    swig
  ];

  buildInputs = [
    octave
    python
  ];

  propagatedBuildInputs = [
    numpy
  ];

  configureFlags = [
    "--with-cxx"
    "--enable-shared"
    "--with-pic"
    "--without-guile"
    "--with-python"
    "--without-matlab"
  ] ++ lib.optionals (octave != null) [
    "--with-octave"
    "M_INSTALL_DIR=$(out)/${octave.sitePath}/m"
    "OCT_INSTALL_DIR=$(out)/${octave.sitePath}/oct"
  ];

  meta = {
    homepage = "https://nlopt.readthedocs.io/en/latest/";
    description = "Free open-source library for nonlinear optimization";
    license = lib.licenses.lgpl21Plus;
    hydraPlatforms = lib.platforms.linux;
  };
}
