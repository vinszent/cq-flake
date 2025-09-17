{
  lib,
  buildPythonPackage,
  hatchling,
  cadquery,
  cadquery-freecad-import-plugin,
  click,
  src,
}:

buildPythonPackage rec {
  pname = "cq-cli";
  version = "2.3.0";
  format = "pyproject";

  inherit src;

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    cadquery
    cadquery-freecad-import-plugin
    click
  ];

  pythonImportsCheck = [ "cq_cli" ];

  meta = with lib; {
    description = "A CLI for executing CadQuery scripts and converting between file formats";
    homepage = "https://github.com/CadQuery/cq-cli";
    license = licenses.asl20;
  };
}
