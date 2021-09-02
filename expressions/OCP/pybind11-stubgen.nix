{ stdenv, buildPythonPackage, src, lib }:

buildPythonPackage rec {
  version = src.shortRev;
  pname = "pybind11-stubgen";

  inherit src;

  pythonImportsCheck = [ "pybind11_stubgen" ];

  meta = with lib; {
    description = "Generates stubs for python modules (targeted to C++ extensions compiled via pybind11)";
    homepage = "https://github.com/cadquery/pybind11-stubgen";
    license = licenses.bsd3;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
