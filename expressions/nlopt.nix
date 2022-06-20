{ lib
  , stdenv
  , fetchFromGitHub
  , cmake
  , octave ? null 
  , python
  , pythonPackages
  , swig
}:

stdenv.mkDerivation rec {
  pname = "nlopt";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "stevengj";
    repo = pname;
    rev = "v${version}";
    sha256 = "0xm8y9cg5p2vgxbn8wn8gqfpxkbm0m4qsidp0bq1dqs8gvj9017v";
  };

  nativeBuildInputs = [
    cmake
    swig
  ];

  buildInputs = [
    octave
    python
  ];

  propagatedBuildInputs = [
    pythonPackages.numpy
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

  # Add python dist-info files so pypi can find it.
  postInstall = ''
    mkdir $out/${python.sitePackages}/nlopt.dist-info
    cat >$out/${python.sitePackages}/nlopt.dist-info/METADATA <<EOL
      Metadata-Version: 2.1
      Name: ${pname}
      Version: ${version}
      EOL
    cat >$out/${python.sitePackages}/nlopt.dist-info/INSTALLER <<EOL
      cmake
      EOL
  '';

  meta = {
    homepage = "https://nlopt.readthedocs.io/en/latest/";
    description = "Free open-source library for nonlinear optimization";
    license = lib.licenses.lgpl21Plus;
    hydraPlatforms = lib.platforms.linux;
  };

}
