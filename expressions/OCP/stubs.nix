{ stdenv, buildPythonPackage, src, lib }:

buildPythonPackage rec {
  version = src.shortRev;
  pname = "ocp-stubs";

  inherit src;

  meta = with lib; {
    description = "PEP 561 type stubs for OCP";
    homepage = "https://github.com/cadquery/ocp-stubs";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
