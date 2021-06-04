{ 
  stdenv
  , lib
  , buildPythonPackage
  , fetchFromGitHub
  , sphinx
  , cadquery
}:

buildPythonPackage rec {
  version = "1.3.3";
  pname = "sphinxcadquery";

  src = fetchFromGitHub {
    owner = "CadQuery";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-cy6dkv9d2NgkqBSAA/G0jv6iQTTlYi1qxGHEdGfIF8o=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    sphinx
  ];

  # not sure if I want to propagate this or not...
  checkInputs = [ cadquery ];

  pythonImportsCheck = [ "sphinxcadquery" ];

  meta = with lib; {
    description = "An extension to visualize CadQuery 3D files in your Sphinx documentation";
    homepage = "https://github.com/CadQuery/sphinxcadquery";
    license = licenses.bsd3;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
