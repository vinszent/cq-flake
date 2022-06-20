{
  stdenv
  , path
  , setuptools_scm
  , lib
  , buildPythonPackage
  , fetchPypi
}:

buildPythonPackage rec {
  version = "12.5.0";
  pname = "path.py";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-jYheiySXrtAFcD2U4P2XlDQB8DXkKhNoEDCL/wNFKag=";
  };

  buildInputs = [ path ];

  nativeBuildInputs = [ setuptools_scm ];

  doCheck = false;

  meta = with lib; {
    description = "path.py has been renamed to path.";
    homepage = "https://github.com/jaraco/path";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

