{ 
  stdenv
  , buildPythonPackage
  , fetchFromGitHub
  , sphinx
  , cadquery
}:

buildPythonPackage rec {
  version = "1.3.2";
  pname = "sphinxcadquery";

  src = fetchFromGitHub {
    owner = "Peque";
    repo = pname;
    rev = "v" + version;
    sha256 = "sha256-oQYKk+77F/4uGtAd1pAZrdsUrHUuZLZTnWUqRVqKDn0=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    sphinx
  ];

  # not sure if I want to propagate this or not...
  checkInputs = [ cadquery ];

  pythonImportsCheck = [ "sphinxcadquery" ];

  meta = with stdenv.lib; {
    description = "An extension to visualize CadQuery 3D files in your Sphinx documentation";
    homepage = "https://github.com/Peque/sphinxcadquery";
    license = licenses.bsd3;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
