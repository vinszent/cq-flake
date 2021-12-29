{
  stdenv
  , lib
  , buildPythonPackage
  , fetchPypi
  , pythonOlder
  , pytest
  , libspatialindex
  , numpy
}:

buildPythonPackage rec {
  version = "0.9.7";
  pname = "Rtree";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vodyyjRpmprT+0z+LPtmKYVORTwQszKAOTAbv8Eoyj4=";
  };

  checkInputs = [ pytest numpy ];

  checkPhase = ''
    python -m pytest --doctest-modules rtree tests
  '';

  SPATIALINDEX_C_LIBRARY = "${libspatialindex}/lib";

  propagatedBuildInputs = [ libspatialindex ];

  meta = with lib; {
    description = "Rtree is a ctypes Python wrapper of libspatialindex.";
    homepage = "https://rtree.readthedocs.io/en/latest/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
