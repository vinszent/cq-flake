{ 
  stdenv
  , lib
  , buildPythonPackage
  , pythonOlder
  , fetchFromGitHub
  , pytest
  , numpy
  , matplotlib
  , plotly
}:

buildPythonPackage rec {
  version = "5.2.10";
  pname = "geomdl";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "orbingol";
    repo = "NURBS-Python";
    rev = "v5.2.10";
    sha256 = "1alg7kjjcs37mpy7dl0s56hbsh0h6zpaamkcwr04xd6nkddarzgn";
    fetchSubmodules = false;
  };

  checkInputs = [ pytest ];

  propagatedBuildInputs = [ numpy matplotlib plotly ];

  meta = with lib; {
    description = "A pure Python, self-contained, object-oriented B-Spline and NURBS spline library";
    homepage = "https://onurraufbingol.com/NURBS-Python/";
    license = licenses.mit;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
